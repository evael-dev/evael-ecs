module evael.ecs.entity;

import evael.ecs.entity_manager;

struct Entity
{
    private EntityManager m_em;
    private Id m_id;

    @nogc
    public this(EntityManager em, in Id id = Id()) nothrow
    {
        this.m_em = em;
        this.m_id = id;
    }

    /**
     * Adds component for this entity.
     */
    @nogc
    public void add(C)(C component)
    {
        assert(this.m_em !is null);
        assert(this.m_id.isValid);

        this.m_em.addComponent!C(this, component);
    }

    /**
     * Returns component of this entity.
     */
    @nogc
    public C* get(C)()
    {
        assert(this.m_em !is null);
        assert(this.m_id.isValid);

        return this.m_em.getComponent!C(this);
    }

    /**
     * Checks if this entity own a specific component.
     */
    @nogc
    public bool has(C)()
    {
        assert(this.m_em !is null);
        assert(this.m_id.isValid);

        return this.m_em.hasComponent!C(this);
    }

    /**
     * Invalidates current entity, but it's still a living entity.
     */
    @nogc
    public void invalidate() nothrow
    {
        this.m_id.isValid = false;
    }

    @nogc
    public int opCmp(in ref Entity rhs) const nothrow
	{
        return this.m_id.opCmp(rhs.id);
	}

    @nogc
    @property nothrow
    {
        public ref const(Id) id() const
        {
            return this.m_id;
        }
    
        public bool isValid() const
        {
            return this.m_id.isValid;
        }
    }
}

struct Id
{
    private size_t m_index;

    public bool isValid = false;

    @nogc
    public this(in size_t index) nothrow
    {
        this.m_index = index;
        this.isValid = true;
    }

    @nogc
    public bool opEquals()(in auto ref Id rhs) const nothrow
    {
        return this.m_index == rhs.index;
    }

    @nogc
    public int opCmp(in ref Id rhs) const nothrow
    {
        if (this.m_index > rhs.index)
        {
            return 1;
        }
        else if (this.m_index == rhs.index)
        {
            return 0;
        }

        return -1;
    }

    @nogc
    @property nothrow
    {
        public size_t index() const
        {
            return this.m_index;
        }

        public void index(in size_t value)
        {
            this.m_index = value;
            this.isValid = true;
        }
    }
}
