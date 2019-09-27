module evael.ecs.components_filter;

/**
 * Mixin template that will help us to generate the components filter for each system.
 */
mixin template ComponentsFilter(Components...)
{
    public Components components;
    
    /// Indicates if the componentsFilter array have already been initialized.
    private bool m_componentsFilterInitialized;

    /// Array containing unique ids of all the components passed to the mixin template.
    private int[Components.length] m_componentsFilter;

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
        if (!this.m_componentsFilterInitialized)
        {
            import evael.ecs.component_counter;

            foreach (index, component; Components)
            {
                this.m_componentsFilter[index] = ComponentCounter!(component).getId();
            }

            this.m_componentsFilterInitialized = true;
        }

        return this.m_componentsFilter;
    }

}
