module evael.ecs.world;

import evael.ecs.entity_manager; 
import evael.ecs.entity; 
import evael.ecs.event_manager;
import evael.ecs.event_receiver;
import evael.ecs.system;
import evael.ecs.system_manager;

import evael.lib.containers.array;

class World : NoGCClass
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
        this.m_entityManager = MemoryHelper.create!EntityManager();
        this.m_systemManager = MemoryHelper.create!SystemManager();
        this.m_eventManager = MemoryHelper.create!EventManager();
    }

    /**
     * World destructor.
     */
    @nogc
    public ~this()
    {
        MemoryHelper.dispose(this.m_entityManager);
        MemoryHelper.dispose(this.m_systemManager);
        MemoryHelper.dispose(this.m_eventManager);
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
     * Params:
     *      entity : entity
     */
    public void killEntity(ref Entity entity)
    {
        auto componentsMasks = this.m_entityManager.getEntityComponentsMasks(entity);
        this.m_systemManager.onEntityKilled(entity, componentsMasks);

        this.m_entityManager.killEntity(entity);
    }

    /**
     * Notifies all systems that an entity is now alive.
     * Params:
     *      entity : entity
     */
    public void activateEntity(ref Entity entity)
    {
        auto componentsMasks = this.m_entityManager.getEntityComponentsMasks(entity);

        this.m_systemManager.onEntityActivated(entity, componentsMasks);
    }

    /**
     * Emits an event to subscribers.
     * Params:
     *      event : event
     */
    public void emitEvent(Event)(Event event)
    {
        this.m_eventManager.emit(event);
    }

    /**
     * Returns a range containing entities with the specified components.
     */
    @nogc
    public Array!Entity getEntitiesWith(Components...)()
    {
        return this.m_entityManager.getEntitiesWith!Components();
    }

    /**
     * Adds a system to the world.
     * Params:
     *      system : system to add
     */
    @nogc
    public void addSystem(System system)
    {
        system.world = this;
        this.m_systemManager.add(system);
    }

    /**
     * Subscribes a receiver to a specific event.
     * Params:
     *      receiver : receiver to subscribes
     */
    @nogc
    public void subscribeReceiverToEvent(Event)(EventReceiver!Event receiver)
    {
        this.m_eventManager.subscribe!Event(receiver);
    }
}