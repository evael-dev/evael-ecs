module tests.entity;

import unit_threaded;
import evael.ecs;

@Setup
void setup()
{
    GlobalComponentCounter counter;
    counter.counter = 0;
}

@Name("Entity is valid")
unittest
{
    auto world = new World();
    auto entity = world.createEntity();

    entity.isValid.shouldEqual(true);
}

@Name("Entity has component")
unittest
{
    auto world = new World();
    auto entity = world.createEntity();
    entity.add(Position(1, 2));

    entity.has!Position().shouldEqual(true);
}

@Name("Entity get returns valid component")
unittest
{
    auto world = new World();
    auto entity = world.createEntity();

    auto position = Position(1, 2);
    entity.add(position);

    (*entity.get!Position()).shouldEqual(position);
}

@Name("Entity is invalid when killed")
unittest
{
    auto world = new World();
    auto entity = world.createEntity();
    world.killEntity(entity);

    entity.isValid.shouldEqual(false);
}


@Name("Id is invalid")
unittest 
{
    Id id;
    id.isValid.shouldEqual(false);
}

@Name("Id is valid")
unittest 
{
    auto id = Id(1);
    id.isValid.shouldEqual(true);
}

@Name("Id comparison")
unittest 
{
    auto id = Id(1);
    auto id2 = Id(1);
    id.shouldEqual(id2);
}

@Name("Id index property")
unittest 
{
    Id id;
    id.index = 1337;
    id.index.shouldEqual(1337);
}

struct Position
{
    public int x;
    public int y;
}