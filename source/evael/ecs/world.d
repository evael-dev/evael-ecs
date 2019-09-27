module evael.ecs.world;

import evael.ecs.entity_manager; 
import evael.ecs.entity; 
import evael.ecs.event_manager;
import evael.ecs.system;
import evael.ecs.system_manager;

import evael.memory;

class World
{
    private EntityManager m_entityManager;
    private SystemManager m_systemManager;
    private EventManager m_eventManager;
    
    /**
     * World constructor.
     */
    @nogc
    public this()
    {
        this.m_entityManager = New!EntityManager();
        this.m_systemManager = New!SystemManager();
        this.m_eventManager = New!EventManager();
    }

    /**
     * World destructor.
     */
    @nogc
    public ~this()
    {
        Delete(this.m_entityManager);
        Delete(this.m_systemManager);
        Delete(this.m_eventManager);
    }

    /**
     * Updates all the systems.
     * Params:
     *      deltaTime : delta time
     */
    public void update(in float deltaTime)
    {
        this.m_systemManager.update(deltaTime);
    }
    
    /**
     * Creates and returns a new entity.
     */
    @nogc
    public Entity createEntity()
    {
        return this.m_entityManager.createEntity();
    }

    /**
     * Kills and notifies all systems that an entity has been killed.
     */
    public void killEntity(ref Entity entity)
    {
        auto componentsMasks = this.m_entityManager.getEntityComponentsMasks(entity);
        this.m_systemManager.onEntityKilled(entity, componentsMasks);

        this.m_entityManager.killEntity(entity);
    }

    /**
     * Notifies all systems that an entity is now alive.
     */
    public void activateEntity(ref Entity entity)
    {
        auto componentsMasks = this.m_entityManager.getEntityComponentsMasks(entity);

        this.m_systemManager.onEntityActivated(entity, componentsMasks);
    }

    /**
     * Adds a system to the world.
     * Params:
     *      system : system to add
     */
    @nogc
    public void addSystem(System system)
    {
        this.m_systemManager.add(system);
    }

    /**
     * Subscribes a system to a specific event.
     * Params:
     *      system : system to subscribes
     */
    @nogc
    public void subscribeToEvent(Event)(System system)
    {
        this.m_eventManager.subscribe!Event(system);
    }
}