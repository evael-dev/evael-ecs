module tests.world;

import unit_threaded;
import evael.ecs;

@Setup
void setup()
{
    GlobalComponentCounter.counter = 0;
    GlobalEventCounter.counter = 0;
}

@Name("World updates system")
unittest
{
    auto world = new World();
    auto system = new MySystem();
    
    world.addSystem(system);
    world.update(1);

    system.updateCalled.shouldEqual(true);
}

@Name("World creates valid entity")
unittest
{
    auto world = new World();
    auto entity = world.createEntity();

    entity.isValid.shouldEqual(true);
}

@Name("World kills entity")
unittest
{
    auto world = new World();
    auto entity = world.createEntity();

    world.killEntity(entity);

    entity.isValid.shouldEqual(false);
}

@Name("World triggers onEntityAlive event when entity activated")
unittest
{
    auto world = new World();
    auto system = new MySystem();
    auto entity = world.createEntity();
    entity.add(Position(1, 2));

    world.addSystem(system);

    system.entityActivated.isValid.shouldEqual(false);

    world.activateEntity(entity);

    system.entityActivated.isValid.shouldEqual(true);
    system.entityActivated.shouldEqual(entity);
}

@Name("World triggers onEntityKilled event when entity killed")
unittest
{
    auto world = new World();
    auto system = new MySystem();
    auto entity = world.createEntity();
    entity.add(Position(1, 2));

    world.addSystem(system);

    system.entityKilled.isValid.shouldEqual(false);

    world.killEntity(entity);

    system.entityKilled.isValid.shouldEqual(true);
    system.entityKilled.shouldEqual(entity);
}

@Name("World returns entities that owns a specific component")
unittest
{
    auto world = new World();
    auto entity = world.createEntity();
    entity.add(Position(1, 2));

    auto entities = world.getEntitiesWith!Position();

    entities.length.shouldEqual(1);
    entities[0].shouldEqual(entity);

    entities = world.getEntitiesWith!(Position, Level)();
    entities.length.shouldEqual(0);

    entity.add(Level(5));

    entities = world.getEntitiesWith!(Position, Level)();
    entities.length.shouldEqual(1);
    entities[0].shouldEqual(entity);
}

@Name("World emits event")
unittest
{
    auto world = new World();
    auto system = new MySystem();

    world.subscribeReceiverToEvent!MovementEvent(system);
    system.movementEventReceived.shouldEqual(false);

    world.emitEvent(MovementEvent(1, 2));
    system.movementEventReceived.shouldEqual(true);
}

/**
 * Fixtures
 */
struct Position
{
    public int x, y;
}

struct Level
{
    int lvl;
}

struct MovementEvent
{
    public int newX, newY;
}

class MySystem : System, EventReceiver!(MovementEvent)
{
    mixin ComponentsFilter!(Position);
    
    public bool updateCalled = false;
    public bool movementEventReceived = false;
    public Entity entityActivated;
    public Entity entityKilled;

    public override void update(in float deltaTime)
    {
        this.updateCalled = true;
    }

    public override void onEntityActivated(ref Entity entity)
    {
        this.entityActivated = entity;
    }

    public override void onEntityKilled(ref Entity entity)
    {
        this.entityKilled = entity;
    }

    public void receive(ref MovementEvent event)
    {
        this.movementEventReceived = true;
    }
}