module tests.components_filter;

import unit_threaded;
import evael.ecs;

@Setup
void setup()
{
    GlobalComponentCounter counter;
    counter.counter = 0;
}

@Name("ComponentsFilters template generates valid filters array")
unittest
{
    auto cameraSystem = new CameraSystem();
    auto levelSystem = new LevelSystem();

    cameraSystem.componentsFilter.length.shouldEqual(1);
    cameraSystem.componentsFilter.shouldEqual([0]);

    levelSystem.componentsFilter.length.shouldEqual(2);
    levelSystem.componentsFilter.shouldEqual([1, 0]);  
}

/**
 * Fixtures
 */
class CameraSystem : System
{
    mixin ComponentsFilter!(Position);

    public override void update(in float deltaTime) 
    {

    }
}

class LevelSystem : System
{
    mixin ComponentsFilter!(Level, Position);

    public override void update(in float deltaTime) 
    {

    }
}


struct Position
{
    public int x;
    public int y;
}

struct Level
{
    public int lvl;
}