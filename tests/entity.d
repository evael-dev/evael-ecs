module tests.entity;

import unit_threaded;
import evael.ecs.entity;

@Name("Id is invalid")
unittest 
{
    Id id;
    id.isValid.shouldEqual(false);
}

@Name("Id is valid")
unittest 
{
    Id id = Id(1);
    id.isValid.shouldEqual(true);
}

@Name("Id comparison")
unittest 
{
    Id id = Id(1);
    Id id2 = Id(1);
    id.shouldEqual(id2);
}

@Name("Id index property")
unittest 
{
    Id id;
    id.index = 1337;
    id.index.shouldEqual(1337);
}