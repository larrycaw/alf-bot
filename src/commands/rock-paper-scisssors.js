const { SlashCommandBuilder } = require('@discordjs/builders');
const { ActionRowBuilder, ButtonBuilder } = require('discord.js');

module.exports = {
    data: new SlashCommandBuilder()
        .setName('rock-paper-scissors')
        .setDescription('Play Rock Paper Scissors with the bot!'),
    async execute(interaction) {
        const row = new ActionRowBuilder()
            .addComponents(
                new ButtonBuilder()
                    .setCustomId('rock')
                    .setLabel('Rock')
                    .setStyle(1),
                new ButtonBuilder()
                    .setCustomId('paper')
                    .setLabel('Paper')
                    .setStyle(1),
                new ButtonBuilder()
                    .setCustomId('scissors')
                    .setLabel('Scissors')
                    .setStyle(1),
            );

        await interaction.reply({content: 'Choose your weapon!', components: [row]});

        const filter = i => i.customId === 'rock' || i.customId === 'paper' || i.customId === 'scissors';
        const collector = interaction.channel.createMessageComponentCollector({filter, time: 15000});

        collector.on('collect', async i => {
            let botChoice = Math.floor(Math.random() * 3);
            let result = '';

            if (botChoice === 0) botChoice = 'rock';
            if (botChoice === 1) botChoice = 'paper';
            if (botChoice === 2) botChoice = 'scissors';


            if (i.customId === botChoice) result = 'It\'s a tie!';

            if (i.customId === 'rock' && botChoice === 'paper') result = 'You lost!';
            if (i.customId === 'rock' && botChoice === 'scissors') result = 'You won!';

            if (i.customId === 'paper' && botChoice === 'scissors') result = 'You lost!';
            if (i.customId === 'paper' && botChoice === 'rock') result = 'You won!';

            if (i.customId === 'scissors' && botChoice === 'rock') result = 'You lost!';
            if (i.customId === 'scissors' && botChoice === 'paper') result = 'You won!';

            await i.update({content: `You chose ${i.customId}, I chose ${botChoice}. ${result}`, components: []});
        });

        collector.on('end', collected => {
            if (collected.size === 0) interaction.editReply({content: 'You didnt choose anything in time!', components: []});
        });
    }
}
