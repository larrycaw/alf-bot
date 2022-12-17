import { ClientEvents, Awaitable, Client } from 'discord.js';

type Logger = (...args: any[]) => void;
export interface EventProperties {
    client: Client;
    log: Logger;
};

export type EventKeys = keyof ClientEvents;
export type EventExec<T extends EventKeys> =
    (props: EventProperties, ...args: ClientEvents[T]) => Awaitable<unknown>;
export interface Event<T extends EventKeys> {
    id: T;
    exec: EventExec<T>
};