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

    /// It's public just because we need to reset it to -1 for utests!
    /// TODO: we shouldn't have to do this...
    public static uint counter = -1;

    @nogc
    public static uint getId() nothrow
    {
        if (counter == -1)
        {
            counter = globalEventCounter.counter++;
        }

        return counter;
    }
}