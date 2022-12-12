import { SlashCommandBuilder } from "@discordjs/builders";
import { ActionRowBuilder, ButtonBuilder } from "discord.js";

export const data = new SlashCommandBuilder()
    .setName("rock-paper-scissors")
    .setDescription("Play Rock Paper Scissors with the bot!");
export async function execute(interaction: any) {
    const row = new ActionRowBuilder().addComponents(
        new ButtonBuilder().setCustomId("rock").setLabel("Rock").setStyle(1),
        new ButtonBuilder().setCustomId("paper").setLabel("Paper").setStyle(1),
        new ButtonBuilder()
            .setCustomId("scissors")
            .setLabel("Scissors")
            .setStyle(1)
    );

    await interaction.reply({
        content: "Choose your weapon!",
        components: [row],
    });

    const filter = (interaction: any) =>
        interaction.customId === "rock" ||
        interaction.customId === "paper" ||
        interaction.customId === "scissors";
    const collector = interaction.channel.createMessageComponentCollector({
        filter,
        time: 15000,
    });

    collector.on("collect", async (i: any) => {
        let botChoiceNumber = Math.floor(Math.random() * 3);
        let botChoice = "";
        let result = "";

        if (botChoiceNumber === 0) botChoice = "rock";
        if (botChoiceNumber === 1) botChoice = "paper";
        if (botChoiceNumber === 2) botChoice = "scissors";

        if (i.customId === botChoice) result = "It's a tie!";

        if (i.customId === "rock" && botChoice === "paper")
            result = "You lost!";
        if (i.customId === "rock" && botChoice === "scissors")
            result = "You won!";

        if (i.customId === "paper" && botChoice === "scissors")
            result = "You lost!";
        if (i.customId === "paper" && botChoice === "rock") result = "You won!";

        if (i.customId === "scissors" && botChoice === "rock")
            result = "You lost!";
        if (i.customId === "scissors" && botChoice === "paper")
            result = "You won!";

        await i.update({
            content: `You chose ${i.customId}, I chose ${botChoice}. ${result}`,
            components: [],
        });
    });

    collector.on("end", (collected: any) => {
        if (collected.size === 0)
            interaction.editReply({
                content: "You didnt choose anything in time!",
                components: [],
            });
    });
}
