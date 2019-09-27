module evael.ecs.component_counter;

struct GlobalComponentCounter
{
    static uint counter = 0;
}

/**
 * Helper used to get an unique id per component.
 */
struct ComponentCounter(Component)
{
    private GlobalComponentCounter globalComponentCounter;

    /// It's public just because we need to reset it to -1 for utests!
    /// TODO: we shouldn't have to do this...
    public static uint counter = -1;

    @nogc
    public static uint getId() nothrow
    {
        if (counter == -1)
        {
            counter = globalComponentCounter.counter++;
        }

        return counter;
    }
}