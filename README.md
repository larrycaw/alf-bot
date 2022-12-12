# alf-bot

# Environment setup

### Prerequisites
- Git
- Node version >= 16.9.0
- Repo cloned

### Install dependencies
Install node modules
```
npm i
```

### Add environment variables
clientId refers to the bots discord id. guildId is a discord servers id. 
To get these id's you have to put discord on developer mode and then you can right click either a server or a person and copy it's id. 
In our case the clientId is the bot's id.
The token can be provided if you're a contributor, if you are just DM me on Discord.

When in root dir of your cloned repo add a new file ".env" with content provided by following instructions above:
```
token=
clientId=
guildId=
```

### Deploy the commands
Once you have your environment variables you are now ready to run your bot.
First you want to deploy the commands to the given server/guild. To do this all you need to do is run deploy-commands.js
```
node deploy-commands.js
```

### You should be good to go!
Launch the bot by running:
```
node index.js
```
