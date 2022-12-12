import {
    SlashCommandBuilder,
    SlashCommandIntegerOption,
} from "@discordjs/builders";

const valueOption = "value";

export const data = new SlashCommandBuilder()
    .setName("fizzbuzz")
    .addIntegerOption((option: SlashCommandIntegerOption) =>
        option
            .setName(valueOption)
            .setDescription("The value to fizz")
            .setRequired(true)
    )
    .setDescription("Fizzer buzzen");

export default async function execute(interaction: any) {
    const value = interaction.options.getInteger(valueOption);
    const fizzedAndBuzzed = fizzBuzz(value);
    await interaction.reply(fizzedAndBuzzed);
}

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
