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

    @nogc
    public static uint getId() nothrow
    {
        static uint counter = -1;

        if (counter == -1)
        {
            counter = globalComponentCounter.counter;
            globalComponentCounter.counter++;
        }

        return counter;
    }
}