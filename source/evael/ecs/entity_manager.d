module evael.ecs.entity_manager;

import evael.ecs.entity;
import evael.ecs.component_pool;

import evael.containers.array;

alias BoolArray = Array!bool;

class EntityManager
{
    enum COMPONENTS_POOL_SIZE = 50;

    /// [ Component1[entity1, entity2...] , Component2[entity1, entity2...] ...]
    private Array!IComponentPool m_components;

    /// [ Entity1[component1, component2...] , Entity2[component1, component2...] ...]
    private Array!BoolArray m_componentMasks;

    private Array!size_t m_freeIds;
    private size_t m_currentIndex;

    @nogc
    public this() nothrow
    {
        this.m_components = Array!IComponentPool(COMPONENTS_POOL_SIZE);
        this.m_components.dispose();

    }

    @nogc
    public ~this()
    {
        foreach (i, poolObject; this.m_components)
        {
            Delete(poolObject);
        }

        foreach (i, maskArray; this.m_componentMasks)
        {
            maskArray.dispose();
        }

        this.m_components.dispose();
        this.m_componentMasks.dispose();
        this.m_freeIds.dispose();
    }

    /**
     * Creates an entity.
     */
    @nogc
    public Entity createEntity()
    {
        auto id = Id();

        if(this.m_freeIds.empty)
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
     *		id :
     *		component :
     */
    @nogc
    public void addComponent(C)(in ref Id id, C component) nothrow
    {
        immutable componentId = this.checkAndAccomodateComponent!C();

        // Adding the component in the pool
        auto pool = cast(ComponentPool!C) this.m_components[componentId];

        assert(pool !is null, "pool is null for component " ~ C.stringof);

        pool.set(id.index, component);

        // Set the mask
        // TODO : dlib.array bug ? I need to type .data before accessing mask
        this.m_componentMasks.data[id.index][componentId] = true;
    }

    /**
     * Retrieves a specific component of an entity.
     * Params:
     *		id :
     */
    @nogc
    public C* getComponent(C)(in ref Id id) nothrow
    {
        immutable componentId = this.checkAndAccomodateComponent!C();

        auto pool = cast(ComponentPool!C) this.m_components[componentId];
        return pool.get(id.index);
    }

    /**
     * Checks if an entity owns a specific component.
     */
    @nogc
    public bool hasComponent(C)(in ref Id id) nothrow
    {
        immutable componentId = this.checkAndAccomodateComponent!C();

        return this.m_componentMasks[id.index][componentId] != false;
    }

    /**
     * Kills an entity.
     * Systems are notified that the specified has been killed.
     */
    @nogc
    public void killEntity(in ref Id id) nothrow
    {
        immutable index = id.index;

        this.m_freeIds.insert(id.index);

        // Notifying systems that an entity has been killed
        auto entity = Entity(this, id);
        this.m_systemManager.onEntityKilled(entity, this.m_componentMasks[index]);

        this.m_componentMasks[index][] = false;
    }

    /**
     * Activates an entity.
     * Systems are notified that a specific entity has been activated.
     */
    @nogc
    public void activateEntity(ref Entity entity) nothrow
    {
        assert(entity.isValid, "Entity is invalid");

        this.m_systemManager.onEntityActivated(entity, this.m_componentMasks[entity.id.index]);
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
            if (this.m_componentMasks.length < nextIndex)
            {
                auto mask = BoolArray();

                for (int i = 0; i < this.m_components.length(); i++)
                {
                    mask.insert(false);
                }

                this.m_componentMasks.insert(mask);
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
}