module evael.ecs.event_receiver;

interface IEventReceiver
{

}

interface EventReceiver(Event) : IEventReceiver
{
    public void receive(ref Event event);
}
