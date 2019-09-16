module evael.ecs.event_manager;

import evael.ecs.event_receiver;
import evael.ecs.event_counter;

import evael.containers.array;

class EventManager
{
    private alias ReceiverArray = Array!IEventReceiver;

    private Array!ReceiverArray m_receivers;

    /**
     * EventManager constructor.
     */
    @nogc
    public this()
    {

    }

    /**
     * EventManager destructor.
     */
    @nogc
    public void dispose()
    {
        foreach (i, ref receiver; this.m_receivers)
        {
            receiver.dispose();
        }

        this.m_receivers.dispose();
    }

    /**
     * Subscribes to an event.
     */
    @nogc
    public void subscribe(Event)(EventReceiver!Event receiver)
    {
        immutable eventId = EventCounter!(Event).getId();

        // We check if we already added this type of event
        if (eventId >= this.m_receivers.length)
        {
            // No, we add it
            auto receivers = ReceiverArray();
            receivers.insert(receiver);

            this.m_receivers.insert(receivers);
        }
        else
        {
            auto receivers = this.m_receivers[eventId];
            receivers.insert(receiver);

            this.m_receivers[eventId] = receivers;
        }
    }

    /**
     * Notifies to all receivers a new event.
     */
    @nogc
    public void emit(Event)(Event event)
    {
        immutable eventId = EventCounter!(Event).getId();

        assert(eventId < this.m_receivers.length);

        foreach (receiver; this.m_receivers[eventId])
        {
            auto r = cast(EventReceiver!Event) receiver;
            r.receive(event);
        }
    }
}
