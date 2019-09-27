module tests.system;

import unit_threaded;
import evael.ecs.system;
import evael.ecs.entity;

@Name("System inserts entity when entity activated")
unittest
{
    auto cameraSystem = new CameraSystem();
    auto entity = Entity(null);
    
    cameraSystem.entitiesCount.shouldEqual(0);

    cameraSystem.onEntityActivated(entity),

    cameraSystem.entitiesCount.shouldEqual(1);
}

@Name("System removes entity when entity killed")
unittest
{
    auto cameraSystem = new CameraSystem();
    auto entity = Entity(null);

    cameraSystem.onEntityActivated(entity),    
    cameraSystem.entitiesCount.shouldEqual(1);

    cameraSystem.onEntityKilled(entity),    
    cameraSystem.entitiesCount.shouldEqual(0);

    cameraSystem.onEntityActivated(entity);

    auto newEntity = Entity(null, Id(7));
    cameraSystem.onEntityKilled(newEntity),    
    cameraSystem.entitiesCount.shouldEqual(1);
}

class CameraSystem : System
{
    public override void update(in float deltaTime)
    {
    }

    @property
    public auto entitiesCount()
    {
        return this.m_entities.length;
    }
}