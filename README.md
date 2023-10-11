Fork of the https://github.com/ggerganov/tweet2doom

Discord bot that can be used to play Doom by sending text based commands as Discord messages.

Also requires https://github.com/ggerganov/doomreplay to work

## How it works
Discord bot made using python reads all the replies coming to ROOT message. If the message starts with '/play', app behind the bot creates a folder. Folder's name is determined by the message id and it contains username that sent the command, the id of the message which it replied to and the /play command itself. After creation the folder is moved to the ./request directory. The implementation is in ./stream directory.

Next part is basically the same as in original tweet2doom. Bash process (./processor/service.sh) handles the entries in the ./requests folder and processes them for ./parse-tweet.cpp. If the file is valid command it is then used to create replay of the game utilising the doomreplay software. ./reply/service.sh process is then used to send the video file back to Discord using Webhook.

## Instructions
Instructions for the game can be found from the https://github.com/ggerganov/tweet2doom

## TODO
- Error handling
- Better README
- Build automation

## Summary
Fun little project which involved reading source code from someone else in multiple languages and using it to create Python application that could communicate with other code. Learned a lot about Bash and Python creating this.





