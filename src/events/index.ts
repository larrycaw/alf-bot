import { Event } from '../types';
import ready from './ready';
import interactionsCreate from './interactionCreate';

const events: Event<any>[] = [
    ready,
    interactionsCreate
];

export default events;