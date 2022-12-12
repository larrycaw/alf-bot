import Discord, { Client, GatewayIntentBits } from "discord.js";
import { config } from "dotenv";
import fs from "fs";

config();

const client = new Client({
    intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages],
});

const commands = new Discord.Collection();
const commandFiles = fs
    .readdirSync("./src/commands")
    .filter((file) => file.endsWith(".js") || file.endsWith(".ts"));

for (const file of commandFiles) {
    const command = await import(`./src/commands/${file}`);
    commands.set(command.data.name, command);
}

client.once("ready", () => {
    console.log("Ready!");
});

client.on("interactionCreate", async (interaction) => {
    if (!interaction.isCommand()) return;

    const command = commands.get(interaction.commandName);

    if (!command) return;

    try {
        await command.execute(interaction);
    } catch (error) {
        console.error(error);
        await interaction.reply({
            content: "There was an error while executing this command!",
            ephemeral: true,
        });
    }
});

client.login(process.env.token);
