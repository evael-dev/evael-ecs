module tests.component_pool;

import unit_threaded;
import evael.ecs.component_pool;

@Name("ComponentPool initializes array with good size")
unittest
{
    auto pool = new ComponentPool!Position(5);
    pool.length.shouldEqual(5);
}

@Name("ComponentPool inserts new component")
unittest
{
    auto pool = new ComponentPool!Position(5);
    pool.insert(Position(1, 2));
    pool.length.shouldEqual(6);
}

@Name("ComponentPool sets and returns component at specified index")
unittest
{
    auto pool = new ComponentPool!Position(5);

    Position posToSet = Position(5, 6);

    pool.set(1, posToSet);
    
    Position* posPtr = pool.get(1);
    
    pool.length.shouldEqual(5);
    (*posPtr).shouldEqual(posToSet);
    posPtr.shouldNotEqual(pool.get(0));
}

@Name("ComponentPool returns a pointer")
unittest
{
    auto pool = new ComponentPool!Position(5);
    auto pos = Position(5, 6);
    pool.set(1, pos);
    
    Position* posPtr = pool.get(1);
    posPtr.x = 10;
    posPtr.y = 11;

    pool.get(1).shouldEqual(posPtr);
}

@Name("ComponentPool expands the pool")
unittest
{
    auto pool = new ComponentPool!Position(1);
    pool.length.shouldEqual(1);
    
    pool.expand();
    pool.length.shouldEqual(2);
}


struct Position
{
    public int x;
    public int y;
}