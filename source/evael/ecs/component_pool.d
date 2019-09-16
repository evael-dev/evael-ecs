module evael.ecs.component_pool;

import evael.containers.array;

interface IComponentPool
{
    @nogc
    public void dispose();

    @nogc
    public void expand();

    @nogc
    public size_t length();
}

class ComponentPool(T) : IComponentPool
{
    private Array!(T) m_components;

    @nogc
    public this(in size_t poolSize)
    {
        while (this.m_components.length < poolSize)
        {
            this.expand();
        }
    }

    @nogc
    public void dispose()
    {
        this.m_components.free();
    }

    @nogc
    public void insert()(auto ref T component)
    {
        this.m_components.insert(component);
    }

    /**
     * Returns the component at the specified index.
     * Params:
     *      index : 
     */
    @nogc
    public T* get(in size_t index)
    {
        assert(index < this.m_components.length);

        return this.m_components[index].data;
    }

    /**
     * Sets the value of the component at the specified index.
     * Params:
     *      index : 
     *      component :
     */
    @nogc
    public void set(in size_t index, ref T component)
    {
        assert(index < this.m_components.length);

        this.m_components[index] = component;
    }

    /**
     * Expands the pool with an empty value.
     */
    @nogc
    public void expand()
    {
        this.m_components.insertBack(T());
    }

    @nogc
    @property nothrow
    public size_t length()
    {
        return this.m_components.length;
    }
}