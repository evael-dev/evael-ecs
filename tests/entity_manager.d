module tests.entity_manager;

import unit_threaded;
import evael.ecs;

@Setup
void setup()
{
    GlobalComponentCounter.counter = 0;
    GlobalEventCounter.counter = 0;
    ComponentCounter!Position.counter = -1;
}

@Name("EntityManager creates valid entity")
unittest
{
    auto em = new EntityManager();

    auto entity = em.createEntity();
    entity.isValid.shouldEqual(true);
}

@Name("EntityManager adds component to a specific entity")
unittest
{
    auto em = new EntityManager();
    auto entity = em.createEntity();

    em.addComponent!Position(entity, Position(5, 6));
    (*em.getComponent!Position(entity)).shouldEqual(Position(5, 6));
}

@Name("EntityManager returns component pointer from a specific entity")
unittest
{
    auto em = new EntityManager();
    auto entity = em.createEntity();

    em.addComponent!Position(entity, Position(5, 6));

    Position* ptr = em.getComponent!Position(entity);
    ptr.x = 1337;
    ptr.y = 1338;
    (*em.getComponent!Position(entity)).shouldEqual(Position(1337, 1338));
}

@Name("EntityManager kills entity")
unittest
{
    auto em = new EntityManager();
    auto entity = em.createEntity();

    em.killEntity(entity);
    entity.isValid.shouldEqual(false);
}

@Name("EntityManager kills entity and add id to freeIds list")
unittest
{
    auto em = new EntityManager();
    auto entity = em.createEntity();

    em.killEntity(entity);

    auto entity2 = em.createEntity();

    entity.isValid.shouldEqual(false);
    entity.id.index.shouldEqual(entity2.id.index);
}

struct Position
{
    int x, y;
}