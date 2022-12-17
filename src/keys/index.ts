import { Keys } from '../types';

const keys: Keys = {
    token: process.env.token ?? 'nil',
    clientId: process.env.clientId ?? 'nil',
    guildId: process.env.guildId ?? 'nil'
};

if(Object.values(keys).includes('nil')) {
    throw new Error('Missing environment variables');
}

export default keys;