import os
import shutil
import discord
import json

# Get the path of current working directory
stream_dir = os.getcwd()

from dotenv import load_dotenv

load_dotenv()
TOKEN = os.getenv("DISCORD_TOKEN")

intents = discord.Intents.default()
intents.message_content = True

client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f'We have logged in as {client.user}')

@client.event
async def on_message(message):
    if message.author == client.user:
        return
    
    if message.content.startswith('/play'):
        msg_id = message.id

        # Create folder named with the message id
        if not os.path.exists(f"{stream_dir}/{msg_id}"):
            os.makedirs(f"{stream_dir}/{msg_id}")

        # Move to the folder
        os.chdir(f"{stream_dir}/{msg_id}")
        
        temp_dir = os.getcwd()

        # Add message's sender to the folder
        if message.author is not None:
            user_id = message.author
            with open("username", "w") as write_file:
                write_file.write(str(user_id))

        # Add parent message id to the folder
        if message.reference is not None:
            referenced_message_id  = message.reference.message_id
            with open('parent_id', 'w') as file:
                file.write(str(referenced_message_id))

        # Add 'play' command to the folder
        await message.channel.send('Generating video...')
        message_json = {"data": {
            "text" : message.content
            }
        }
        with open("payload.json", "w") as write_file:
            json.dump(message_json, write_file)

        # Move the directory to the 'requests' directory
        shutil.move(temp_dir, '/home/olli/programming/DiscorDoom/requests')

    
        # Move back to the original directory
        os.chdir(stream_dir)


    elif message.webhook_id == 1150800688738209802:
        return
    else:
        await message.channel.send(f'Invalid command on message {message.id}')



client.run(TOKEN)