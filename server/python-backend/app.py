import asyncio
from flask import Flask, request, jsonify
import mysql.connector
import openai
from openai import AzureOpenAI
from flask_cors import CORS
import json
import re
from datetime import datetime, timedelta


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
    cursor.execute("SELECT item, quantity_with_unit, expiry FROM ingredients WHERE quantity_with_unit > 0")
    ingredients = cursor.fetchall()
    ingredients_list = [f"{row[1]} {row[2]} of {row[0]}" for row in ingredients]
    return jsonify({"ingredients": ingredients_list})


# API endpoint to generate recipes (Settle)
@app.route('/generate-recipe', methods=['POST'])
def generate_recipe_api():
    data = request.json
    ingredients = data.get('ingredients')
    if not ingredients:
        return jsonify({"error": "No ingredients provided"}), 400

    prompt = f"""
    Using the following ingredients: {ingredients}, suggest 4 simple and healthy breakfast recipe names only. Do not include detailed steps or descriptions, just the names of the recipes.
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


# Generate Recipes overview using the recipe_name from the selected name (Settle)
@app.route('/generate-recipe-overview', methods=['POST'])
def generate_recipe_overview():
    data = request.json
    recipe_name = data.get('recipe_name')
    
    if not recipe_name:
        return jsonify({"error": "Recipe name is required"}), 400
    
    prompt = f"""
    Provide an overview of the recipe "{recipe_name}" in the following structured format:
    
    Recipe name: [Name]
    
    Ingredients:
    - [Ingredient 1]
    - [Ingredient 2]
    - [Ingredient 3]
    
    Required equipment:
    - [Equipment 1]
    - [Equipment 2]
    - [Equipment 3]
    
    Ensure the structure remains consistent. **Do not include optional toppings or garnish.**
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
    
    # Process the response
    overview_lines = response.choices[0].text.strip().split("\n")
    
    # Ensure correct structure
    structured_data = {
        "recipe_name": "",
        "ingredients": [],
        "equipment": []
    }

    section = None
    for line in overview_lines:
        line = line.strip()
        if line.startswith("Recipe name:"):
            structured_data["recipe_name"] = line.replace("Recipe name:", "").strip()
        elif line.startswith("Ingredients:"):
            section = "ingredients"
        elif line.startswith("Required equipment:"):
            section = "equipment"
        elif section == "ingredients" and line.startswith("-"):
            structured_data["ingredients"].append(line.lstrip("-").strip())
        elif section == "equipment" and line.startswith("-"):
            structured_data["equipment"].append(line.lstrip("-").strip())

    return jsonify({
        "recipe_name": structured_data["recipe_name"],
        "ingredients": structured_data["ingredients"],
        "equipment": structured_data["equipment"]
    })


# Swap Ingredients in case dun have
@app.route('/swap-ingredient', methods=['POST'])
def swap_ingredient():
    data = request.json
    missing_ingredient = data.get("ingredient")

    if not missing_ingredient:
        return jsonify({"error": "Ingredient not provided"}), 400

    # 🔥 Query GPT-3.5 for ingredient alternatives
    prompt = f"""
    I am missing {missing_ingredient} in my kitchen. Suggest 3 alternative ingredients along with their appropriate quantities that I can use instead. 
    Provide the response in the following format:
    "(Quantity) Alternative Ingredient, (Quantity) Alternative Ingredient, (Quantity) Alternative Ingredient"
    Ensure each alternative ingredient is properly formatted with its quantity.
    Example:
    "1/4 cup Applesauce, 1 tbsp Chia Seeds, 3 tbsp Aquafaba"
    Do NOT use numbering (1, 2, 3), 'and', or newline characters. 
    Keep it consistent.
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

    # Extract alternative ingredients from GPT-3.5 response
    alternative_text = response.choices[0].text.strip()
    if alternative_text.startswith('"') and alternative_text.endswith('"'):
            alternative_text = alternative_text[1:-1]
    alternatives = [
            alt.strip().capitalize()  # Capitalize first letter of each alternative
            for alt in alternative_text.replace("\n", ", ").split(",")  # Ensure proper splitting
            if alt.strip().lower() not in ["and"]  # Remove "and"
        ]
    print("Alternatives", alternatives)
    return jsonify({"alternatives": alternatives})


# Generate Recipe Steps using the recipe name and ingredient selected earlier
@app.route('/generate-recipe-steps', methods=['POST'])
def generate_recipe_steps():
    data = request.json
    recipe_name = data.get('recipe_name')
    ingredients = data.get('ingredients')

    if not recipe_name:
        return jsonify({"error": "Recipe name is required"}), 400
    
    if not ingredients or not isinstance(ingredients, list):
        return jsonify({"error": "Valid ingredient list is required"}), 400

    # Format ingredients properly for GPT request
    formatted_ingredients = "\n".join([f"- {ingredient}" for ingredient in ingredients])
    print("Updated Ingredients List:", formatted_ingredients)

    prompt = f"""
    Generate a simple step-by-step guide for cooking "{recipe_name}" with a focus on parent-child collaboration. Using the following ingredients: {formatted_ingredients}.Each step must include:
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


# Not used for now
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










# For Camera Component

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

                # save_filtered_ingredients_to_db(filtered_ingredients, user_id)

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
    


# API endpoint to fetch and filter kitchen list based on user ID
@app.route('/api/inventory-list', methods=['GET'])
def get_inventory_list():
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

                save_filtered_ingredients_to_db(filtered_ingredients, user_id)

                # Call the generate_recipe function directly
                # recipes = generate_recipe_from_ingredients(filtered_ingredients)
                return jsonify({
                    # "kitchen_list": filtered_ingredients,
                    # "recipes": recipes.get("recipe", [])
                }), 200

            return jsonify({"kitchen_list": filtered_ingredients}), 200
        else:
            return jsonify({"error": "No kitchen list found for the given userID"}), 404
    except Exception as e:
        print(f"Error retrieving kitchen list: {e}")
        return jsonify({"error": "Internal server error"}), 500
    

def save_filtered_ingredients_to_db(filtered_ingredients, user_id):
    """Insert filtered ingredients into the database."""
    try:
        for ingredient_name in filtered_ingredients:
            # Capitalize the first letter of the ingredient name
            ingredient_name = ingredient_name.capitalize()
            # Check if the ingredient already exists for the user
            cursor.execute(
                """
                SELECT id FROM ingredients WHERE item = %s AND userID = %s
                """,
                (ingredient_name, user_id)
            )
            existing_ingredient = cursor.fetchone()

            if not existing_ingredient:
                # Calculate expiry date as 30 days from today
                expiry_date = (datetime.now() + timedelta(days=30)).date()  # Add 30 days
                
                # Insert the ingredient with NULL quantity and expiry
                cursor.execute(
                    """
                    INSERT INTO ingredients (item, quantity_with_unit, expiry, userID) 
                    VALUES (%s, '', %s, %s)
                    """,
                    (ingredient_name, expiry_date, user_id)
                )
                conn.commit()
                print(f"Ingredient '{ingredient_name}' saved to the database.")
            else:
                print(f"Ingredient '{ingredient_name}' already exists in the database.")
    except Exception as e:
        print(f"Error saving filtered ingredients to the database: {e}")


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
