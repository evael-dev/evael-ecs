module evael.ecs.system;

import evael.ecs.entity;
import evael.ecs.world;

import evael.lib.containers.array;

abstract class System : NoGCClass
{
    /**
     * Defines if update() function will be automatically called by the system manager or manually by the user.
     */
    enum UpdatePolicy
    {
        Automatic,
        Manual
    }

    protected Array!Entity m_entities;

    protected UpdatePolicy m_updatePolicy;

    protected int[] m_componentsFilter;

    protected World m_world;

    /**
     * System constructor.
     */
    @nogc
    public this(UpdatePolicy updatePolicy = UpdatePolicy.Automatic)
    {
        this.m_updatePolicy = updatePolicy;
    }

    /**
     * System destructor.
     */
    @nogc
    public ~this()
    {
        this.m_entities.dispose();
    }

    /**
     *
     */
    public abstract void update(in float deltaTime);

    /**
     * Registers current system's components if they are not known by the entity manager.
     * Note: Only useful when a ComponentFilters mixin is used in the user system.
     */
    @nogc
    public void registerComponents()
    {
        
    }

    /**
     * Returns a static array containing components ids.
     * Note: Only useful when a ComponentFilters mixin is used in the user system.
     */
    @nogc
    @property
    public int[] componentsFilter()
    {
        return [];
    }


    /**
     * Event called when new entity that satisfies current system's components filter has been activated.
     */
    public void onEntityActivated(ref Entity entity)
    {
        this.m_entities.insert(entity);
    }

    /**
     * Event called when a new entity that satisfies current system's components filter has been killed.
     */
    public void onEntityKilled(ref Entity entity)
    {
        import std.algorithm;

        auto index = this.m_entities[].countUntil!(e => e.id == entity.id);

        if (index >= 0)
        {
            this.m_entities.removeAt(index);
        }
    }

    @nogc
    @property nothrow
    {
        public ref const(UpdatePolicy) updatePolicy() const
        {
            return this.m_updatePolicy;
        }

        public void updatePolicy(in UpdatePolicy value)
        {
            this.m_updatePolicy = value;
        }

        package void world(World world)
        {
            this.m_world = world;
        }
    }
}