module tests.event_counter;

import unit_threaded;
import evael.ecs.event_counter;

@Setup
void setup()
{
    GlobalEventCounter.counter = 0;
    EventCounter!PositionEvent.counter = -1;
    EventCounter!LevelUpEvent.counter = -1;
}

@Name("GlobalEventCounter is unique")
unittest
{
    GlobalEventCounter globalEventCounter;
    GlobalEventCounter globalEventCounter2;

    globalEventCounter.counter++;
    globalEventCounter.counter.shouldEqual(1);
    globalEventCounter2.counter.shouldEqual(1);
}

@Name("Templated EventCounter returns a valid id")
unittest
{
    EventCounter!PositionEvent positionEventCounter;
    positionEventCounter.getId().shouldEqual(0);
}

@Name("Templated EventCounter returns a unique id")
unittest
{
    EventCounter!PositionEvent positionEventCounter;
    EventCounter!LevelUpEvent levelEventCounter;

    positionEventCounter.getId().shouldEqual(0);
    levelEventCounter.getId().shouldEqual(1);
    GlobalEventCounter.counter.shouldEqual(2);
}

struct PositionEvent
{
    public int x;
    public int y;
}

struct LevelUpEvent
{
    public int level;
}