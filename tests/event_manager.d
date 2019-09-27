module tests.event_manager;

import unit_threaded;
import evael.ecs;

@Setup
void setup()
{
    GlobalComponentCounter.counter = 0;
    GlobalEventCounter.counter = 0;
    EventCounter!PositionEvent.counter = -1;
    EventCounter!JumpEvent.counter = -1;
}

@Name("EventManager emits event to a single system")
unittest
{ 
    EventManager eventManager = new EventManager();
    CameraSystem system = new CameraSystem();

    eventManager.subscribe!PositionEvent(system);

    system.receivedPositionEvent.shouldEqual(false);

    eventManager.emit(PositionEvent(1, 2));

    system.receivedPositionEvent.shouldEqual(true);
}

@Name("EventManager emits events to multiple systems")
unittest
{
    EventManager eventManager = new EventManager();
    CameraSystem system = new CameraSystem();
    CameraSystem system2 = new CameraSystem();
    
    eventManager.subscribe!PositionEvent(system);
    eventManager.subscribe!PositionEvent(system2);
    eventManager.subscribe!JumpEvent(system2);

    eventManager.emit(PositionEvent(1, 2));

    system.receivedPositionEvent.shouldEqual(true);
    system.receivedJumpEvent.shouldEqual(false);

    system2.receivedPositionEvent.shouldEqual(true);
    system2.receivedJumpEvent.shouldEqual(false);

    eventManager.emit(JumpEvent());

    system.receivedPositionEvent.shouldEqual(true);
    system.receivedJumpEvent.shouldEqual(false);

    system2.receivedPositionEvent.shouldEqual(true);
    system2.receivedJumpEvent.shouldEqual(true);
}

/**
 * Fixtures
 */
class CameraSystem : EventReceiver!PositionEvent, EventReceiver!JumpEvent
{
    public bool receivedPositionEvent = false;
    public bool receivedJumpEvent = false;

    public void receive(ref PositionEvent event)
    {
        this.receivedPositionEvent = true;
    }

    public void receive(ref JumpEvent event)
    {
        this.receivedJumpEvent = true;
    }
}

struct PositionEvent
{
    public int x;
    public int y;
}

struct JumpEvent
{

}