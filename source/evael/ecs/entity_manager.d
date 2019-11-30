module evael.ecs.entity_manager;

import evael.ecs.entity;
import evael.ecs.component_pool;
import evael.ecs.component_counter;

import evael.lib.containers.array;

import std.traits;

alias BoolArray = Array!bool;

class EntityManager : NoGCClass
{
    enum COMPONENTS_POOL_SIZE = 50;

    /// [ Component1[entity1, entity2...] , Component2[entity1, entity2...] ...]
    private Array!IComponentPool m_components;

    /// [ Entity1[component1, component2...] , Entity2[component1, component2...] ...]
    private Array!BoolArray m_componentsMasks;

    private Array!size_t m_freeIds;
    private size_t m_currentIndex;

    /**
     * EntityManager constructor.
     */
    @nogc
    public this() nothrow
    {
        this.m_components = Array!IComponentPool(COMPONENTS_POOL_SIZE);
    }

    /**
     * EntityManager destructor.
     */
    @nogc
    public ~this()
    {
        foreach (i, maskArray; this.m_componentsMasks)
        {
            maskArray.dispose();
        }

        this.m_components.dispose();
        this.m_componentsMasks.dispose();
        this.m_freeIds.dispose();
    }

    /**
     * Creates an entity.
     */
    @nogc
    public Entity createEntity()
    {
        auto id = Id();

        if (this.m_freeIds.empty)
        {
            id.index = this.m_currentIndex;
            this.initializeEntityData(id.index);
        }
        else
        {
            id.index = this.m_freeIds.back;
            this.m_freeIds.removeBack();
        }

        return Entity(this, id);
    }

    /**
     * Adds a component for an entity.
     * Params:
     *		entity :
     *		component :
     */
    @nogc
    public void addComponent(C)(in ref Entity entity, C component)
    {
        immutable componentId = this.checkAndRegisterComponent!C();

        // Adding the component in the pool
        auto pool = cast(ComponentPool!C) this.m_components[componentId];

        assert(pool !is null, "pool is null for component " ~ __traits(identifier, C));

        pool.set(entity.id.index, component);

        // Set the mask
        this.m_componentsMasks[entity.id.index][componentId] = true;
    }

    /**
     * Retrieves a specific component of an entity.
     * Params:
     *		entity :
     */
    @nogc
    public C* getComponent(C)(in ref Entity entity)
    {
        immutable componentId = this.checkAndRegisterComponent!C();

        auto pool = cast(ComponentPool!C) this.m_components[componentId];
        return pool.get(entity.id.index);
    }

    /**
     * Checks if an entity owns a specific component.
     * Params:
     *		entity :
     */
    @nogc
    public bool hasComponent(C)(in ref Entity entity)
    {
        immutable componentId = this.checkAndRegisterComponent!C();

        return this.m_componentsMasks[entity.id.index][componentId] != false;
    }

    /**
     * Checks if a component is already known.
     */
    @nogc
    public int checkAndRegisterComponent(C)()
    {
        immutable componentId = ComponentCounter!(C).getId();

        if (this.m_components.length <= componentId)
        {
            // Not know yet, we register it
            this.registerComponent!C(componentId);
        }

        return componentId;
    }

    /**
     * Kills an entity.
     * Params:
     *		entity :
     */
    @nogc
    public void killEntity(ref Entity entity) nothrow
    {
        immutable index = entity.id.index;

        entity.invalidate();

        this.m_componentsMasks[index][] = false;

        this.m_freeIds.insert(index);
    }

    /**
     * Returns a range containing entities with the specified components.
     */
    @nogc
    public Array!Entity getEntitiesWith(Components...)()
    {
        Array!Entity entities;

        if (this.m_components.length == 0)
        {
            return entities;
        }

        import std.bitmanip : BitArray;

        auto askedComponentsMask = this.getComponentsMask!Components();
        
        for (size_t i = 0; i < this.m_currentIndex; i++)
        {
            auto entityComponentsMask = this.m_componentsMasks[i];
            
            auto combinedMask = BoolArray(askedComponentsMask.length, false);
            combinedMask.data[] = entityComponentsMask.data[] & askedComponentsMask.data[];

            if (combinedMask == askedComponentsMask)
            {
                entities.insert(Entity(this, Id(i)));
            }

            combinedMask.dispose();
        }

        askedComponentsMask.dispose();

        return entities;
    }

    /**
     * Returns components masks of an entity.
     * Params:
     *		entity :
     */
    @nogc
    public bool[] getEntityComponentsMasks(in ref Entity entity) nothrow
    {
        return this.m_componentsMasks[entity.id.index][];
    }

    /**
     * Initializes arrays of components / masks for a specific entity.
     * Params:
     *      index : entity index
     */
    @nogc
    private void initializeEntityData(in size_t index)
    {
        immutable nextIndex = index + 1;

        if (index >= this.m_currentIndex)
        {
            // Expand component mask array
            if (this.m_componentsMasks.length < nextIndex)
            {
                auto mask = BoolArray(this.m_components.length(), false);
                this.m_componentsMasks.insert(mask);
            }

            // Expand all component arrays
            if (this.m_components.length > 0 && this.m_components[0].length < nextIndex)
            {
                foreach (i, componentPool; this.m_components)
                {
                    componentPool.expand();
                }
            }
        }

        this.m_currentIndex = nextIndex;
    }

    /**
     * Registers a component.
     * Params:
     *		componentId :
     */
    @nogc
    private void registerComponent(C)(in int componentId)
    {
        // Expanding component pool
        auto componentPool = MemoryHelper.create!(ComponentPool!C)(this.m_currentIndex);
        this.m_components.insert(componentPool);

        // Expanding all components masks to include a new component
        if (this.m_componentsMasks.length > 0 && this.m_componentsMasks[0].length <= componentId)
        {
            foreach (ref componentMask; this.m_componentsMasks)
            {
                componentMask.insert(false);
            }
        }
    }

    /**
     * Returns a mask with the specified components.
     */
    public BoolArray getComponentsMask(Components...)()
    {
        auto mask = BoolArray(this.m_components.length(), false);

        foreach (component; Components)
        {
            immutable componentId = ComponentCounter!(component).getId();

            // We check if that component is known
            if(this.m_components.length <= componentId)
            {
                // Nop, register it
                this.registerComponent!component(componentId);
                mask.insert(true);
            }
            else mask[componentId] = true;
        }

        return mask;
    }
}