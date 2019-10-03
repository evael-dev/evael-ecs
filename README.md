<!-- LOGO -->
<p align="center">
  <h2 align="center">evael-ecs</h2>
  <p align="center">
    <a href="https://github.com/evael-dev/evael-lib/actions">
        <img src="https://github.com/evael-dev/evael-lib/workflows/CI/badge.svg">
    </a>
    <a href="https://codecov.io/gh/evael-dev/evael-lib">
        <img src="https://codecov.io/gh/evael-dev/evael-lib/branch/master/graph/badge.svg" />
    </a>
    <img src="https://img.shields.io/github/license/evael-dev/evael-lib">
    <br />
  </p>
</p>

- - -

**evael-ecs** is the entity-component-system used by the **Evael** engine. It's supposed to be fully **@nogc**.

It's inspired by the following projects : 

* https://github.com/miguelmartin75/anax  => C++ ECS
* https://github.com/jzhu98/star-entity   => D ECS
* https://github.com/claudemr/entitysysd  => D ECS

## Build

You have to use [dub](https://code.dlang.org/download) to build the project.
Add this project as a dependency to your **dub.json**: dub add evael-ecs

## Getting Started
### World

World is the class that will handle everything for you. You should use it to add systems, create entities and subscribe to events.

```cs

import evael.ecs;
import evael.lib;

void main()
{
    auto world = MemoryHelper.create!World();

    while(game)
    {
        world.update(dt);
    }
    
    MemoryHelper.dispose(world);
}
```

### Entities

You can create an entity, kill it, invalidate it or activate it.

```cs
auto entity = world.createEntity();

// Notifies all systems that a new entity is alive
world.activateEntity(entity);)

// Entity is still alive but will be invalid in current scope
entity.invalidate();

// Notifies all systems that an entity has been killed
world.killEntity(entity);)

```

### Components

A component must be represented as a struct.

```cs
struct PositionComponent
{
    float x, y, z;
}
```

You can add a component to an entity :

```cs
// add
entity.add!PositionComponent(1, 2, 3);

// update (its handled as a pointer)
entity.get!PositionComponent().y = 50;

// check
if(entity.has!PositionComponent())
{
    // ...
}
```
### Systems

A system must be a class that inherits **evael.ecs.system**.

```cs
class MovementSystem : System
{
    public void update(in float delta)
    {

    }
}
```

There are 2 ways to query entities from your system : 

* 1 => Using entity manager **getEntitiesWith!(components...)** method
* 2 => Using the ComponentsFilter mixin template **mixin ComponentsFilter!(components...);**

If you provide a components filter, when an entity is activated, it will be automatically added to the systems whose filters match her components.

```cs
class MovementSystem : System
{
    // option 2
    mixin ComponentsFilter!(PositionComponent);

    public void update(in float deltaTime)
    {
        // option 1
        auto entities = this.m_entityManager.getEntitiesWith!(PositionComponent);

        // option 2 (should be more efficient)
        foreach (entity; this.m_entities)
        {

        }
    }
}
```
The update method of the system will be automatically called by the entity manager in the main loop. If you want to handle the update manually, you can set the **System.UpdatePolicy** to manual :

```cs
class MovementSystem : System
{
    public this()
    {
        super(System.UpdatePolicy.Manual);
    }
}

// ...

while(game)
{
    world.update(dt);

    // you have to call it manually (before or after the world.update call)
    myMovementSystem.update(dt);
}
```

### Events

A receiver is a class that implements **Receiver(EventType)** interface.

```cs
// An event must be a struct
struct MovementEvent
{
    Entity entityThatMoved;
    int newX, newY;
}

// The receiver
class CameraSystem : Receiver!MovementEvent
{
    /**
     * Movement event received from a system
     */
    public void receive(ref MovementEvent event)
    {
        // ...
    }
}

// Subscribe to events
void main()
{
    auto world = MemoryHelper.create!World();
    auto cameraSys = MemoryHelper.create!CameraSystem();

    world.addSystem(cameraSys);
    world.subscribeReceiverToEvent!MovementEvent(cameraSys);
}
```

You can send events from systems by using the **m_world.emit** method.

```cs
// Sending an event from the MovementSystem
class MovementSystem : Receiver!MovementEvent
{
    public void update(in float deltaTime)
    {
        foreach (entity; this.m_entities)
        {
            this.m_world.emit(MovementEvent(entity));
        }
    }
}
```