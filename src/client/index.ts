import { Client, GatewayIntentBits } from 'discord.js';
import { registerEvents } from '../utils/event';
import events from '../events';
import keys from '../keys';

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.GuildMembers
        ]
});

registerEvents(client, events);

client.login(keys.token)
    .catch((error) => {
       console.error('[LOGIN ERROR]', error);
       process.exit(1);
    });