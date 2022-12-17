import { Event, EventExec, EventKeys } from '../types';
import { Client } from 'discord.js';

export function event<T extends EventKeys>(id: T, exec: EventExec<T>): Event<T> {
    return { id, exec };
}

export function registerEvents(client: Client, events: Event<EventKeys>[]) {
    for (const event of events) {
        client.on(event.id, async (...args) => {
            // create props
            const props = {
                client,
                log: (...args: unknown[]) => console.log(`[${event.id}]`, ...args)
            }

            // catch uncaught errors
            try {
                await event.exec(props, ...args);
            } catch (error) {
                props.log(`[EVENT ERROR]`, error);
            }
        });
    }
}
