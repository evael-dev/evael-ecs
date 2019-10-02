module tests.system_manager;

import unit_threaded;
import evael.ecs;
import evael.lib.containers.array;

@Setup
void setup()
{
    GlobalComponentCounter.counter = 0;
    GlobalEventCounter.counter = 0;
    ComponentCounter!Position.counter = -1;
}

@Name("SystemManager update system")
unittest
{
    auto systemManager = new SystemManager();
    auto cameraSystem = new CameraSystem();

    systemManager.update(0);

    cameraSystem.updated.shouldEqual(false);

    systemManager.add(cameraSystem);
    systemManager.update(0);

    cameraSystem.updated.shouldEqual(true);
}

@Name("SystemManager doesn't call update for system with Manual update policy")
unittest
{
    auto systemManager = new SystemManager();
    auto cameraSystem = new CameraSystem();
    cameraSystem.updatePolicy = System.UpdatePolicy.Manual;

    systemManager.update(0);

    cameraSystem.updated.shouldEqual(false);

    systemManager.add(cameraSystem);
    systemManager.update(0);

    cameraSystem.updated.shouldEqual(false);
}

@Name("SystemManager update systems")
unittest
{
    auto systemManager = new SystemManager();
    auto cameraSystem = new CameraSystem();
    auto octreeSystem = new OctreeSystem();

    systemManager.add(cameraSystem);
    systemManager.add(octreeSystem);

    systemManager.update(0);

    cameraSystem.updated.shouldEqual(true);
    octreeSystem.updated.shouldEqual(true);
}

import std.typecons;

struct TestProvider
{
    bool mask;
    bool shouldEqual;
}

@Name("SystemManager trigger onEntityActivated event")
@Values
(
    TestProvider(true, true),
    TestProvider(false, false)
)
unittest
{   
    auto entity = Entity(null);
    auto systemManager = new SystemManager();
    auto cameraSystem = new CameraSystem();
    
    auto testProvider = getValue!(TestProvider, 0);
    
    systemManager.add(cameraSystem);
    systemManager.onEntityActivated(entity, [testProvider.mask]);

    cameraSystem.onEntityActivatedCalled.shouldEqual(testProvider.shouldEqual);
}

@Name("SystemManager trigger onEntityKilled event")
@Values
(
    TestProvider(true, true),
    TestProvider(false, false)
)
unittest
{
    auto entity = Entity(null);
    auto systemManager = new SystemManager();
    auto cameraSystem = new CameraSystem();
    
    auto testProvider = getValue!(TestProvider, 0);
    
    systemManager.add(cameraSystem);
    systemManager.onEntityKilled(entity, [testProvider.mask]);

    cameraSystem.onEntityKilledCalled.shouldEqual(testProvider.shouldEqual);
}

/**
 * Fixtures
 */
class CameraSystem : System
{
    mixin ComponentsFilter!(Position);

    public bool updated = false;
    public bool onEntityActivatedCalled = false;
    public bool onEntityKilledCalled = false;

    public override void update(in float deltaTime)
    {
        this.updated = true;
    }

    public override void onEntityActivated(ref Entity entity)
	{
		this.onEntityActivatedCalled = true;
	}

    public override void onEntityKilled(ref Entity entity)
	{
		this.onEntityKilledCalled = true;
	}
}

class OctreeSystem : System
{
    public bool updated = false;

    public override void update(in float deltaTime)
    {
        this.updated = true;
    }
}

struct Position
{
    public int x;
    public int y;
}