import asyncio
from flask import Flask, request, jsonify
import mysql.connector
import openai
from openai import AzureOpenAI
from flask_cors import CORS
import json
import re

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
    ingredients = data.get('ingredients')

    if not recipe_name:
        return jsonify({"error": "Recipe name is required"}), 400
    
    formatted_ingredients = "\n".join([f"- {ingredient}" for ingredient in ingredients])


    prompt = f"""
    Generate a step-by-step guide for cooking "{recipe_name}" with a focus on parent-child collaboration. Using the following ingredients: {formatted_ingredients}.Each step must include:
    1. A "step" field with the cooking process instruction.
    2. A "motivation" field with a short, encouraging motivational message.

    Categorize steps as:
    - Parents: Tasks that involve sharp objects, hot surfaces, or dangerous equipment.
    - Children: Tasks that are safer or more fun, such as mixing or decorating.
    - Everyone: Tasks that involve teamwork.

    Return the response as a valid JSON array where each object has "step" and "motivation" keys. Example format:
    [
      {{
        "step": "Step 1 (parent): Preheat the oven to 350°F.",
        "motivation": "Great job handling the oven! You're awesome!"
      }},
      {{
        "step": "Step 2 (child): Mix the dry ingredients in a bowl.",
        "motivation": "You're doing a fantastic job mixing!"
      }}
    ]
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

    try:
        steps = json.loads(response.choices[0].text.strip())
    except json.JSONDecodeError:
        return jsonify({"error": "Failed to parse steps. Check prompt and response formatting."}), 500

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

# Define a function to extract potential ingredients
def extract_ingredient(item):
    """
    Extract potential ingredient names from descriptive phrases.
    Match both individual words and multi-word phrases.
    """
    # Normalize the item to lowercase and remove unnecessary characters
    normalized_item = item.lower()

    # Check for exact multi-word ingredient matches first
    matched_ingredients = [
        ingredient for ingredient in VALID_INGREDIENTS
        if ingredient in normalized_item
    ]

    return matched_ingredients


# Define a list of valid ingredients
VALID_INGREDIENTS = [
    "butter", "chicken", "chicken breasts", "garlic", "tomato", "onion",
    "salt", "pepper", "parsley", "basil",
    "carrot", "potato", "cucumber", "zucchini", "broccoli", "cauliflower",
    "spinach", "lettuce", "kale", "celery", "eggplant", "green beans",
    "mushrooms", "sweet potato", "corn", "apple", "banana", "lemon", "lime",
    "orange", "grapes", "pineapple", "strawberry", "avocado", "blueberry",
    "raspberry", "watermelon", "mango", "pear", "kiwi", "cherry", "cilantro",
    "rosemary", "thyme", "oregano", "dill", "sage", "paprika", "cumin",
    "turmeric", "ginger", "cinnamon", "nutmeg", "clove", "black pepper",
    "chili powder", "curry powder", "beef", "pork", "fish", "shrimp", "turkey",
    "eggs", "bacon", "ham", "lamb", "tofu", "tempeh", "milk", "cheese", "cream",
    "yogurt", "sour cream", "cream cheese", "rice", "pasta", "bread", "quinoa",
    "oats", "barley", "lentils", "chickpeas", "black beans", "kidney beans",
    "olive oil", "vegetable oil", "sesame oil", "soy sauce", "vinegar",
    "mustard", "ketchup", "mayonnaise", "honey", "maple syrup", "sugar",
    "vanilla extract", "baking powder", "baking soda", "yeast", "flour",
    "breadcrumbs", "crab", "lobster", "clams", "scallops", "squid", "anchovies",
    "sardines", "almonds", "walnuts", "cashews", "peanuts", "sunflower seeds",
    "chia seeds", "pumpkin seeds", "flaxseeds", "chocolate", "cocoa powder",
    "coconut milk", "coconut flakes", "stock", "broth", "gelatin", "yellow powder",
    "white powder", 
]

# API endpoint to fetch and filter kitchen list based on user ID
@app.route('/api/kitchen-list', methods=['GET'])
def get_kitchen_list():
    user_id = request.args.get('userID')
    print(f"Received user_id: {user_id}")
    if not user_id:
        return jsonify({"error": "userID is required"}), 400

    try:
        cursor.execute(
            """
            SELECT kitchenList 
            FROM KITCHEN 
            WHERE userID = %s 
            ORDER BY added_at DESC 
            LIMIT 1
            """, 
            (user_id,)
        )
        result = cursor.fetchone()
        print(f"SQL Result: {result}")
        if result:
            kitchen_list = result[0].split(", ")
            print(f"Original kitchen list: {kitchen_list}")

            # Filter valid ingredients
            filtered_ingredients = []
            for item in kitchen_list:
                extracted_ingredients = extract_ingredient(item)
                filtered_ingredients.extend(extracted_ingredients)

            # Remove duplicates and maintain order
            filtered_ingredients = list(dict.fromkeys(filtered_ingredients))
            print(f"Filtered ingredients: {filtered_ingredients}")

            # Automatically generate recipes if valid ingredients exist
            if filtered_ingredients:
                # Call the generate_recipe function directly
                recipes = generate_recipe_from_ingredients(filtered_ingredients)
                return jsonify({
                    # "kitchen_list": filtered_ingredients,
                    "recipes": recipes.get("recipe", [])
                }), 200

            return jsonify({"kitchen_list": filtered_ingredients}), 200
        else:
            return jsonify({"error": "No kitchen list found for the given userID"}), 404
    except Exception as e:
        print(f"Error retrieving kitchen list: {e}")
        return jsonify({"error": "Internal server error"}), 500


# Helper function to generate recipes directly
def generate_recipe_from_ingredients(ingredients):
    prompt = f"""
    Using the following ingredients: {', '.join(ingredients)}, suggest 4 simple and healthy recipe names only. 
    Do not include detailed steps or descriptions, just the names of the recipes.
    """
    try:
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
        # Clean up numbering or extra characters
        recipe_list = [recipe.lstrip('0123456789. ') for recipe in recipe_list]
        return {"recipe": recipe_list}
    except Exception as e:
        print(f"Error generating recipes: {e}")
        return {"error": "Failed to generate recipes"}




if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
