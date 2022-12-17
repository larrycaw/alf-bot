import {
    InteractionReplyOptions,
    WebhookEditMessageOptions,
} from 'discord.js'

export const colors = {
    error: 0xf54242
}

export const reply = {
    error(msg: string): InteractionReplyOptions {
        return {
            ephemeral: true,
            embeds: [{
                color: colors.error,
                description: msg
            }]
        }
    }
}

export const editReply = {
    error(msg: string): WebhookEditMessageOptions {
        return {
            embeds: [{
                color: colors.error,
                description: msg
            }]
        }
    }
}
