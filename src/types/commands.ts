import { Awaitable, Client, ChatInputCommandInteraction, SlashCommandBuilder } from 'discord.js';

type Logger = (...args: any[]) => void;
export interface CommandProperties {
    interaction: ChatInputCommandInteraction;
    client: Client;
    log: Logger;
};

export type CommandExec =
    (props: CommandProperties) => Awaitable<unknown>;
export type CommandMeta =
    | SlashCommandBuilder
    | Omit<SlashCommandBuilder, "addSubcommand" | "addSubcommandGroup">;
export interface Command {
    meta: CommandMeta;
    exec: CommandExec;
};

export interface CommandCategory {
    name: string;
    commands: Command[];
};
