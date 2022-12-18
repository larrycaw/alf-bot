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
Once you have your environment variables you are now ready to deploy your commands to the bot.
All you need to do is run
```
npm run deploy
```

### Building the project
As we are using typescript in this project we need to build the project into javascript files.
We have a command for this as well.
```
npm run build
```

### You should be good to go!
Launch the bot by running:
```
npm run start
```
