module evael.ecs.event_counter;

struct GlobalEventCounter
{
    static uint counter = 0;
}

/**
 * Helper used to get an unique id per event.
 */
struct EventCounter(Event)
{
    private GlobalEventCounter globalEventCounter;

    @nogc
    public static uint getId() nothrow
    {
        static uint counter = -1;

        if (counter == -1)
        {
            counter = globalEventCounter.counter;
            globalEventCounter.counter++;
        }

        return counter;
    }
}