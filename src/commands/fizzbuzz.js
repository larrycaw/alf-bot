const { SlashCommandBuilder } = require("@discordjs/builders");

const valueOption = "value";

module.exports = {
    data: new SlashCommandBuilder()
        .setName("fizzbuzz")
        .addIntegerOption((option) =>
            option
                .setName(valueOption)
                .setDescription("The value to fizz")
                .setRequired(true)
        )
        .setDescription("Fizzer buzzen"),

    async execute(interaction) {
        const value = interaction.options.getInteger(valueOption);
        const fizzedAndBuzzed = fizzBuzz(value);
        await interaction.reply(fizzedAndBuzzed);
    },
};

function fizzBuzz(value) {
    const v = Number(value);
    if (v % 15 === 0) {
        return "FizzBuzz";
    }
    if (v % 3 === 0) {
        return "Fizz";
    }
    if (v % 5 === 0) {
        return "Buzz";
    }

    return v.toString();
}
