import { REST } from "@discordjs/rest";
import { Routes } from "discord-api-types/v10";
import { config } from "dotenv";
import { readdirSync } from "fs";

config();

const commands = [];
const commandFiles = readdirSync("./src/commands").filter(
    (file) => file.endsWith(".js") || file.endsWith(".ts")
);

for (const file of commandFiles) {
    const command = require(`./src/commands/${file}`);
    commands.push(command.data.toJSON());
}

const rest = new REST({ version: "10" }).setToken(process.env.token);

(async () => {
    try {
        console.log("Started refreshing application (/) commands.");

        await rest.put(
            Routes.applicationGuildCommands(
                process.env.clientId,
                process.env.guildId
            ),
            { body: commands }
        );

        console.log("Successfully reloaded application (/) commands.");
    } catch (error) {
        console.error(error);
    }
})();
