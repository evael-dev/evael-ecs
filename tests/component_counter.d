module tests.component_counter;

import unit_threaded;
import evael.ecs.component_counter;

@Setup
void setup()
{
    GlobalComponentCounter.counter = 0;
    ComponentCounter!Position.counter = -1;
    ComponentCounter!Level.counter = -1;
}

@Name("GlobalComponentCounter is unique")
unittest
{
    GlobalComponentCounter globalComponentCounter;
    GlobalComponentCounter globalComponentCounter2;
    globalComponentCounter.counter.shouldEqual(0);
    globalComponentCounter2.counter.shouldEqual(0);

    globalComponentCounter.counter++;
    globalComponentCounter.counter.shouldEqual(1);
    globalComponentCounter2.counter.shouldEqual(1);
}

@Name("Templated ComponentCounter returns a valid id")
unittest
{
    ComponentCounter!Position positionComponentCounter;
    positionComponentCounter.getId().shouldEqual(0);
}

@Name("Templated ComponentCounter returns a unique id")
unittest
{
    ComponentCounter!Position positionComponentCounter;
    ComponentCounter!Level levelComponentCounter;
    GlobalComponentCounter globalComponentCounter;

    positionComponentCounter.getId().shouldEqual(0);
    levelComponentCounter.getId().shouldEqual(1);
    globalComponentCounter.counter.shouldEqual(2);
}

struct Position
{
    public int x;
    public int y;
}

struct Level
{
    public int level;
}