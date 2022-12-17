import {
    SlashCommandBuilder,
    SlashCommandIntegerOption,
} from "discord.js";
import { command } from '../../utils';

const valueOption = "value";

const meta = new SlashCommandBuilder()
    .setName("fizzbuzz")
    .addIntegerOption((option: SlashCommandIntegerOption) =>
        option
            .setName(valueOption)
            .setDescription("The value to fizz")
            .setRequired(true)
    )
    .setDescription("Fizzer buzzen");

export default command(meta, ({ interaction }) => {
    const value = interaction.options.getInteger(valueOption);
    const fizzedAndBuzzed = fizzBuzz(value ?? 0);
    interaction.reply(fizzedAndBuzzed);
});

function fizzBuzz(value: number): string {
    if (value % 15 === 0) {
        return "FizzBuzz";
    }
    if (value % 3 === 0) {
        return "Fizz";
    }
    if (value % 5 === 0) {
        return "Buzz";
    }

    return value.toString();
}
