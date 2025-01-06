import asyncio
from flask import Flask, request, jsonify
import mysql.connector
import openai
from openai import AzureOpenAI
from flask_cors import CORS
import json

app = Flask(__name__)
CORS(app)

# Set your OpenAI API key


# Connect to MySQL Database
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="7aF54E0c31",
    database="Cookaiga"
)
cursor = conn.cursor()

# API endpoint to fetch ingredients
@app.route('/ingredients', methods=['GET'])
def get_ingredients():
    cursor.execute("SELECT name, quantity, unit FROM ingredients WHERE quantity > 0")
    ingredients = cursor.fetchall()
    ingredients_list = [f"{row[1]} {row[2]} of {row[0]}" for row in ingredients]
    return jsonify({"ingredients": ingredients_list})

# API endpoint to generate recipes
@app.route('/generate-recipe', methods=['POST'])
def generate_recipe_api():
    data = request.json
    ingredients = data.get('ingredients')
    if not ingredients:
        return jsonify({"error": "No ingredients provided"}), 400

    prompt = f"""
    Using the following ingredients: {ingredients}, suggest 4 simple and healthy recipe names only. Do not include detailed steps or descriptions, just the names of the recipes.
    """
    
    response = client.completions.create(
        model="gpt-35-turbo-instruct",
        prompt=prompt,
        temperature=1,
        max_tokens=1000,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0
    )
    recipe_list = response.choices[0].text.strip().split("\n")
    # Remove numbering if any (like '1. Tomato')
    recipe_list = [recipe.lstrip('0123456789. ') for recipe in recipe_list]
    return jsonify({"recipe": recipe_list})


@app.route('/generate-recipe-overview', methods=['POST'])
def generate_recipe_overview():
    data = request.json
    recipe_name = data.get('recipe_name')
    
    if not recipe_name:
        return jsonify({"error": "Recipe name is required"}), 400
    
    prompt = f"""
    Provide an overview of the recipe "{recipe_name}". Include:
    1. Recipe name
    2. Ingredients
    3. Required equipment
    """
    response = client.completions.create(
        model="gpt-35-turbo-instruct",
        prompt=prompt,
        temperature=1,
        max_tokens=1000,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0
    )
    
    # Process the overview and remove empty lines
    overview = response.choices[0].text.strip().split("\n")
    overview = [line for line in overview if line.strip()]  # Remove empty lines

    # Optional: Clean up section headers and "-" prefixes
    processed_overview = []
    for line in overview:
        # Remove numbered prefixes (e.g., "1.", "2.", "3.")
        if line.strip().startswith(("1.", "2.", "3.")):
            line = line.split(".", 1)[1].strip()  # Remove the number prefix
        
        # Remove "-" at the start of a line
        if line.strip().startswith("-"):
            line = line.strip().lstrip("-").strip()  # Remove the dash and extra spaces
        
        processed_overview.append(line)
    
    return jsonify({"overview": processed_overview})


@app.route('/generate-recipe-steps', methods=['POST'])
def generate_recipe_steps():
    data = request.json
    recipe_name = data.get('recipe_name')

    if not recipe_name:
        return jsonify({"error": "Recipe name is required"}), 400

    prompt = f"""
    Generate a step-by-step cooking guide for the recipe "{recipe_name}". Each step should assign roles and responsibilities as follows:
    - Parents handle tasks that involve sharp objects, hot surfaces, or dangerous equipment (e.g., knives, ovens, stoves).
    - Children handle safer, simpler, or more fun tasks (e.g., mixing, pouring, cracking eggs, decorating).
    - Everyone handles tasks that involve teamwork or activities that can be enjoyed together (e.g., setting up the counter, taste testing, serving).
    - Use motivational and encouraging language suitable for ADHD individuals. Include fun phrases or comments to keep them engaged.
    - Clearly indicate who is responsible for each step with "parent", "child", or "everyone" at the beginning of the step.

    Example:
    Step 1 (everyone): Gather all the ingredients together as a team. You’re the ultimate cooking squad!
    Step 2 (child): Crack the eggs into the bowl. Remember, messy hands mean you’re doing it right!
    Step 3 (parent): Chop the vegetables with a knife. Show off your pro skills while staying safe!
    Step 4 (everyone): Taste the batter together to make sure it’s just right. Add a little extra magic if needed!
    Step 5 (parent): Heat the pan and cook the pancakes. Flip like a master chef!
    Step 6 (child): Add toppings and decorate the pancakes. Make it as colorful as you like!
    """
    response = client.completions.create(
        model="gpt-35-turbo-instruct",
        prompt=prompt,
        temperature=1,
        max_tokens=1500,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0
    )

    # Process and return steps
    steps = response.choices[0].text.strip().split("\n")
    steps = [step for step in steps if step.strip()]  # Remove empty lines

    return jsonify({"steps": steps})




@app.route('/generate-recipe-images', methods=['POST'])
async def generate_recipe_images():
    data = request.json
    recipe_names = data.get('recipe_names')
    if not recipe_names or not isinstance(recipe_names, list):
        return jsonify({"error": "A list of recipe names must be provided"}), 400

    async def fetch_image(recipe_name):
        prompt = f"Create a beautiful and appetizing cartoon illustration of {recipe_name}, in a playful and vibrant cartoon style."
        response = await asyncio.to_thread(client.images.generate,  # Run in thread pool
                                           model="dall-e-3",
                                           prompt=prompt,
                                           n=1)
        return recipe_name, json.loads(response.model_dump_json())['data'][0]['url']

    # Run all requests concurrently
    results = await asyncio.gather(*[fetch_image(recipe_name) for recipe_name in recipe_names])

    # Build dictionary of recipe names and their respective image URLs
    image_urls = {name: url for name, url in results}

    return jsonify({"image_urls": image_urls})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
