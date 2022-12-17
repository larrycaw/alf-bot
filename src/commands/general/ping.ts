import { SlashCommandBuilder } from 'discord.js';
import { command } from '../../utils';

const meta = new SlashCommandBuilder()
    .setName('ping')
    .setDescription('Replies with Pong!');

export default command(meta, ({ interaction }) => {
    return interaction.reply({
        ephemeral: true,
        content: 'Pong! 🏓'
    })
});