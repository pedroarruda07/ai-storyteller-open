from flask import Flask, jsonify, request, Response
#import openai
import os
import random
import requests
import base64
import requests
import logging
import google.generativeai as genai

logging.basicConfig(level=logging.INFO)

themes = ['Love','Family','Friendship','Hero','Revenge','Good versus evil','Justice','Power','Faith']
genres = ['Fantasy', 'Action', 'Mystery', 'Sci-Fi', 'Thriller', 'Drama', 'Romance']

def generate_random(type):
    num = random.randint(0, len(type)-1)
    return type[num]

app = Flask(__name__)

#openai.api_key = os.getenv("OPENAI_API_KEY")
genai.configure(api_key=os.environ["GEMINI_API"])

@app.route('/placeholder-endpoint', methods=['POST'])
def generate_story():
    """
    Generate a story using Google's Gemini model.

    This endpoint accepts a JSON payload containing parameters that describe
    the type of story to generate (theme, genre, characters, etc.), and uses
    the Gemini API to create a narrative and corresponding image prompt.

    The response includes:
      - The full story text.
      - A generated title.
      - A short prompt suitable for image generation (story cover).
    """

    #get the JSON data from the request
    data = request.json

    required_fields = ['theme', 'genre', 'words', 'forKids', "language"]
    
    #check for the presence of all required fields
    missing_fields = [field for field in required_fields if field not in data]
    
    if missing_fields:
        return (f"Missing required fields: {', '.join(missing_fields)}"), 400

    # Uses helper function to build prompt based on user input
    prompt = build_prompt(data)

    try:
        generation_config = {
        "temperature": 1,
        "top_p": 0.95,
        "top_k": 40,
        "max_output_tokens": 8192,
        "response_mime_type": "application/json",
        }
        
        #call gemini 2.0 flash to generate the story
        model = genai.GenerativeModel(
        model_name=os.getenv("GEMINI_MODEL", "gemini-2.0-flash-lite"),
        generation_config=generation_config,
        # TODO safety_settings = Adjust safety settings with kids mode
        #https://ai.google.dev/gemini-api/docs/safety-settings
        )

        chat_session = model.start_chat(history=[])

        response = chat_session.send_message(prompt)

        return jsonify({'story': response.text})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


def build_prompt(data: dict) -> str:
    """
    Build the full text-generation prompt for the Gemini model.

    This helper constructs a detailed story-generation prompt string based on 
    the input JSON payload. It includes all contextual information such as 
    theme, genre, characters, plot, setting, and language.
    """
    #extract variables from the JSON data
    characters = data.get('characters')
    plot = data.get('plot')
    theme = data.get('theme')
    genre = data.get('genre')
    words = data.get('words')
    forKids = data.get('forKids')
    setting = data.get('setting')
    language = data.get('language')

    if (theme == 'Random'):
        theme = generate_random(themes)

    if (genre == 'Random'):
        genre = generate_random(genres)

    # --- create the prompt ----
    prompt = (f"Write a {genre} story ")

    if (forKids):
        prompt += "for kids "

    if (setting):
        prompt += f"set in {setting} "

    if (characters):
        prompt += (f"with the main character {characters.pop(0)}")
        if (len(characters) >= 1):
                prompt += (f" and the following side characters: ")
                for character in characters :
                    prompt += f"{character}; "
                prompt += "\nMake sure to include all characters listed."
    else:
        num = random.randint(1, 10)
        if (num <= 3):
            prompt += f"\nWhen naming characters and places, use *RANDOM* names and take into account that it's a {genre} story."
        if (num > 3 and num <= 6):
            prompt += "\nUse simple and realistic names for characters and DO NOT name places unless explicit somewhere else in this prompt."   
                 
    prompt += (f"\nThe story should revolve around the theme of {theme}.")

    if plot:
        prompt += f" Use the following plot as the basis for the story: {plot}."

    if (forKids):
        prompt += "\nMake sure to use simple language since the story has to be written for kids."

    prompt += "\nThink about the title only after generating the entire story."

    prompt += (f"\nKeep the story around {words} words and always separate paragraphs with an empty line.\nAfter creating the story and the title, create a prompt to be used to generate an image to be the story's cover."
            "In this prompt make sure you mention the genders of the characters." 
            "Keep this prompt under 50 words."
            "\nReturn the response in a valid json format with the attributes 'Text', 'Title' and 'Prompt'. Don't add any unncessary characters when formatting the json.\n"
            "Example:\n"
            '{\n"Text": (body of the story)\n'
            '"Title": (title of the story)\n'
            '"Prompt": (prompt to generate story cover image)\n}'
            )
    
    if (language != "English"):
        prompt += (f'\nTranslate the title and the body of the story to {language} before returning the response. Make sure you only translate these two things. '
        '*DO NOT* translate the prompt or the name of the attributes in the json (e.g: "Text", "Title", "Prompt")')

    return prompt




engine_id = os.getenv("STABILITY_ENGINE", "stable-diffusion-xl-1024-v1-0")
api_host = 'https://api.stability.ai'
api_key = os.getenv("IMAGE_API_KEY")

@app.route("/placeholder-endpoint", methods=['POST'])
def generate_image():
    """
    Generate an story illustration using Stability AI's text-to-image API.

    This endpoint accepts a short text prompt (generated by the story endpoint)
    and a chosen visual style, then returns a 1024x1024 PNG image generated by
    Stable Diffusion.
    """

    data = request.json

    prompt = data.get('prompt')
    style = data.get('style')
    
    if not prompt or not style:
        return jsonify({'error': 'No prompt or style provided.'}), 400
    
    final_prompt = ''

    if(style == "realistic"):
            final_prompt = f"A photograph of {prompt}"
    elif(style == "cartoon"):
            final_prompt = f"Cartoon of {prompt}"
    elif(style == "fantasy"):
            final_prompt = f"Fantasy style art of {prompt}"
    elif(style == "painting"):
            final_prompt = f"{prompt}, oil painting by Da Vinci"
    elif(style == "anime"):
            final_prompt = f"Anime style image of {prompt}"
    elif(style == "comics"):
            final_prompt = f"{prompt}, super-hero comics book style"
    elif(style == "cyberpunk"):
            final_prompt = f"Cyberpunk style image of {prompt}"
            

    response = requests.post(
        f"{api_host}/v1/generation/{engine_id}/text-to-image",
        headers={
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": f"Bearer {api_key}"
        },
        json={
            "text_prompts": [
                {
                    "text": final_prompt,
                }
            ],
            "cfg_scale": 7,
            "height": 1024,
            "width": 1024,
            "samples": 1,
            "steps": 30,
        },
    )
    
    # logging.info(final_prompt)

    if response.status_code != 200:
        return jsonify({'error': f"Image generation failed: {response.text}"}), response.status_code

    data = response.json()

    #decode the image
    image_base64 = data["artifacts"][0]["base64"]
    image_data = base64.b64decode(image_base64)

    #return the decoded image bytes as a valid PNG image response
    return Response(image_data, mimetype='image/png')


#if __name__ == '__main__':
   #app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
#  app.run()
