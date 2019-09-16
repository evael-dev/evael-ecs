module evael.ecs.components_filter;

/**
 * Mixin template that will help us to generate the components filter for each system.
 */
mixin template ComponentsFilter(Components...)
{
    /// Array containing unique ids of all the components passed to the mixin template.
    private int[Components.length] m_componentsFilter;

    /**
     * Registers current system's component if they are not know by the entity manager.
     */
    @nogc
    public override void registerComponents()
    {
        assert(this.m_entityManager !is null);

        foreach (component; Components)
        {
            this.m_entityManager.checkAndAccomodateComponent!component();
        }
    }

    /**
     * Returns a static array containing components ids.
     *
     * When called for the first time, this function will initialize the ids of 
     * all the components passed to the template.
     */
    @nogc
    @property
    public override int[] componentsFilter()
    {
        static bool initialized = false;

        if (!initialized)
        {
            import evael.ecs.component_counter;

            foreach (index, component; Components)
            {
                this.m_componentsFilter[index] = ComponentCounter!(component).getId();
            }

            initialized = true;
        }

        return this.m_componentsFilter;
    }

}
