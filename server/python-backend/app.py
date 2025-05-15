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
client = AzureOpenAI(
    # Enter Own API Key, API Version, Azure_EndPoint
    api_key="", 
    api_version="",
    azure_endpoint=""
)


# Connect to MySQL Database
# Uses MySQL Database 
conn = mysql.connector.connect(
    host="",
    user="",
    password="",
    database=""
)
cursor = conn.cursor()

@app.route('/ingredients', methods=['GET'])
def get_ingredients():
    try:
        conn = mysql.connector.connect(
            host="",
            user="",
            password="",
            database=""
        )
        cursor = conn.cursor()

        query = "SELECT item, quantity_with_unit, expiry FROM ingredients WHERE quantity_with_unit != ''"
        cursor.execute(query)
        ingredients = cursor.fetchall()

        ingredients_list = [
            f"{row[1]} of {row[0]} expiring on {row[2]}" for row in ingredients
        ]

        print("Fetched ingredients:", ingredients_list)
        return jsonify({"ingredients": ingredients_list})

    except mysql.connector.Error as err:
        print("MySQL Error:", err)
        return jsonify({"error": str(err)}), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


# API endpoint to generate recipes
@app.route('/generate-recipe', methods=['POST'])
def generate_recipe_api():
    data = request.json # Gets the JSON payload from the incoming POST request
    ingredients = data.get('ingredients')
    print (ingredients) # Prints the received ingredients to the console for debugging
    if not ingredients:
        return jsonify({"error": "No ingredients provided"}), 400 # Returns an error response if ingredients are missing

    # Construct the prompt to send to Azure OpenAI
    prompt = f"""
    Using the following ingredients: {ingredients}, suggest 4 simple and healthy lunch recipe names only. 
    Do not include detailed steps or descriptions, just the names of the recipes.
    """
    # Calls Azure OpenAI with the prompt using GPT-3.5-turbo-instruct model
    response = client.completions.create(
        model="gpt-35-turbo-instruct",
        prompt=prompt,
        temperature=1,
        max_tokens=1000,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0
    )
    # Takes the text output, strips any extra whitespace, and splits by new line into a list
    recipe_list = response.choices[0].text.strip().split("\n")
    # Remove numbering if any (like '1. Tomato')
    recipe_list = [recipe.lstrip('0123456789. ') for recipe in recipe_list]
    # Print
    print("Generated Recipe Names:")
    for idx, recipe in enumerate(recipe_list, start=1):
        print(f"{idx}. {recipe}")
    # Returns the list of recipe names as a JSON response
    return jsonify({"recipe": recipe_list})

# Generate based on individual ingredient from inventory page
@app.route('/generate-recipe-from-ingredient', methods=['POST'])
def generate_recipe_from_single_ingredient():
    # It reads the JSON payload sent to this route and extracts the value of the "ingredient" key.
    data = request.json
    ingredient = data.get('ingredient')

    # If no ingredient is provided, return an HTTP 400 Bad Request with an error message.
    if not ingredient:
        return jsonify({"error": "No ingredient provided"}), 400

    # Attempts to connect to the MySQL database using credentials. (mysql.connector is the Python library used)
    try:
        conn = mysql.connector.connect(
            host="",
            user="",
            password="",
            database=""
        )
        # A cursor is created for executing SQL queries.
        cursor = conn.cursor()

        # Use parameterized query to avoid SQL injection & syntax errors
        query = "SELECT item, quantity_with_unit, expiry FROM ingredients WHERE item = %s AND quantity_with_unit != ''"
        cursor.execute(query, (ingredient,))
        # Retrieves the first matching ingredient row from the DB. Returns None if not found.
        row = cursor.fetchone()

        #  If no ingredient found: Returns a 404 Not Found with appropriate error message.
        if not row:
            return jsonify({"error": "Ingredient not found or quantity empty"}), 404
        
        #  If no ingredient found: Returns a 404 Not Found with appropriate error message.
        formatted_ingredient = f"{row[1]} of {row[0]} expiring on {row[2]}"
        print("Using ingredient:", formatted_ingredient)

        # This prompt is crafted to instruct the GPT model to generate 4 simple recipe names using the given ingredient info.
        prompt = f"""
        Using the following ingredient: {formatted_ingredient}, suggest 4 simple and healthy lunch recipe names only.
        Do not include detailed steps or descriptions, just the names of the recipes.
        """

        response = client.completions.create(
            #  the specific model used.
            model="gpt-35-turbo-instruct",
            prompt=prompt,
            # higher creativity.
            temperature=1,
            # max response length.
            max_tokens=1000,
            # etc., control response randomness
            top_p=1,
            frequency_penalty=0,
            presence_penalty=0
        )
        # Splits the result by lines.
        # Strips any leading numbers like 1., 2) from each recipe name.
        
        recipe_list = response.choices[0].text.strip().split("\n")
        recipe_list = [recipe.lstrip('0123456789. ').strip() for recipe in recipe_list]

        # Prints the final cleaned recipe list to your console (for debugging/logging).
        print("Generated Recipe Names:")
        for i, r in enumerate(recipe_list, 1):
            print(f"{i}. {r}")

        # Returns the final cleaned list of recipe names to the frontend as a JSON response.
        return jsonify(recipe_list)
    
    # If any MySQL-specific error occurs, it logs it and returns a 500 Internal Server Error.
    except mysql.connector.Error as err:
        print("MySQL Error:", err)
        return jsonify({"error": str(err)}), 500

    # Ensures both cursor and DB connection are closed, whether the query was successful or not.
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


@app.route('/generate-recipe-overview', methods=['POST'])
def generate_recipe_overview():
    data = request.json
    recipe_name = data.get('recipe_name')
    user_id = data.get('userID')  # Optionally pass userID for user-specific ingredients

    if not recipe_name:
        return jsonify({"error": "Recipe name is required"}), 400

    try:
        # 🔌 Connect to DB
        conn = mysql.connector.connect(
            host="",
            user="",
            password="",
            database=""
        )
        cursor = conn.cursor()

        # 🎯 Query distinct ingredient items (optionally filter by user)
        if user_id:
            cursor.execute("SELECT DISTINCT item FROM ingredients WHERE userID = %s", (user_id,))
        else:
            cursor.execute("SELECT DISTINCT item FROM ingredients")

        db_ingredients = cursor.fetchall()
        allowed_ingredients = [row[0].lower() for row in db_ingredients]
        ingredient_list = ", ".join(allowed_ingredients)

    except Exception as e:
        print("❌ DB Error:", e)
        return jsonify({"error": "Failed to load ingredients from DB"}), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

    # 📦 Prompt GPT with your dynamic ingredients
    prompt = f"""
        You are a smart kitchen assistant. Create a recipe overview for "{recipe_name}".

        You must ONLY use ingredients from this list: {ingredient_list}. Do NOT include any other items.

        Format:
        Recipe name: [Name]

        Ingredients:
        - [Quantity and unit] [Ingredient 1]
        - [Quantity and unit] [Ingredient 2]

        Required equipment:
        - [Equipment 1]
        - [Equipment 2]

        ❗STRICT RULES:
        - Use ONLY listed ingredients
        - NO extra toppings, spices, or seasonings
        - Follow the structure exactly
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

    overview_lines = response.choices[0].text.strip().split("\n")

    structured_data = {
        "recipe_name": "",
        "ingredients": [],
        "equipment": []
    }

    section = None
    for line in overview_lines:
        line = line.strip()
        if not line:
            continue

        if line.lower().startswith("recipe name:"):
            structured_data["recipe_name"] = line.split(":", 1)[1].strip()
        elif line.lower().startswith("ingredients:"):
            section = "ingredients"
        elif line.lower().startswith("required equipment:") or line.lower().startswith("equipment:"):
            section = "equipment"
        elif section in {"ingredients", "equipment"} and line.startswith("-"):
            cleaned = line.lstrip("-").strip()
            if section == "ingredients":
                structured_data["ingredients"].append(parse_ingredient(cleaned))
            else:
                structured_data["equipment"].append(cleaned)

    return jsonify(structured_data)


def parse_ingredient(line):
    """
    Extracts unit + quantity + item cleanly from GPT output.
    Input: "1 cup marinara sauce" → Output: "1 cup marinara sauce"
    Handles edge cases like "2 cloves garlic, minced"
    """
    line = line.replace(",", "")  # Remove commas like 'garlic, minced'

    parts = line.split()
    if len(parts) < 2:
        return line  # Not enough info, return raw

    # Try to grab quantity + unit
    quantity = parts[0]
    unit = parts[1] if len(parts) > 1 else ""
    ingredient = " ".join(parts[2:]) if len(parts) > 2 else " ".join(parts[1:])

    # Smart fallback for fractional quantities (like 1/2)
    try:
        float(quantity)  # if it's valid, proceed
    except:
        if '/' in quantity:
            try:
                float(eval(quantity))  # test if it's like '1/2'
            except:
                return line  # not parsable
        else:
            return line  # no quantity detected

    return f"{quantity} {unit} {ingredient}".strip()



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
    Generate a short, simple step-by-step guide for cooking "{recipe_name}" with a focus on parent-child collaboration. Using the following ingredients: {formatted_ingredients}.Each step must include:
    1. Each step must include only **one clear action**.
    2. A "motivation" field with a short, encouraging motivational message.
    3. Use **short and simple sentences**
    4. Be fun and easy to follow for both parents and children.
    5. Do NOT use vague phrases like "cook as per package" or "season to taste".
    6. Always provide concrete instructions (e.g., "Boil the noodles in water for 5 minutes").

    Categorize steps as:
    - (parent): For tasks that involve sharp tools (like cutting, slicing, or chopping) or anything hot (like using the stove or oven).
    - (child): For safe and fun tasks such as stirring, mixing, decorating, sprinkling, or setting the table.
    - Everyone: Steps that need teamwork

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
    Using the following ingredients: {', '.join(ingredients)}, suggest 4 simple and healthy lunch recipe names only 
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
        print("Generated Recipes:")
        for i, recipe in enumerate(recipe_list, 1):
            print(f"{i}. {recipe}")

        return {"recipe": recipe_list}
    except Exception as e:
        print(f"Error generating recipes: {e}")
        return {"error": "Failed to generate recipes"}
    

UNIT_CONVERSIONS = {
    # 🥬 Vegetables & Herbs
    'onion': ('pieces', 0.5),
    'chopped onion': ('pieces', 0.5),
    'onion chopped': ('pieces', 0.5),
    'carrot': ('pieces', 0.5),
    'carrot sliced': ('pieces', 0.5),
    'tomato': ('pieces', 1.0),
    'diced tomato': ('pieces', 1.0),
    'garlic': ('pieces', 0.5),
    'minced garlic': ('pieces', 0.5),
    'garlic cloves': ('pieces', 0.5),
    'cloves garlic': ('pieces', 0.5),
    'celery': ('stalks', 1.0),
    'spinach': ('cups', 1.0),
    'broccoli': ('cups', 1.0),
    'broccoli florets': ('cups', 1.0),
    'bell pepper': ('pieces', 1.0),
    'pepper': ('grams', 2.3),  # fallback to black pepper

    # 🌾 Grains & Rice
    'rice': ('cups', 1.0),
    'brown rice': ('cups', 1.0),
    'white rice': ('cups', 1.0),
    'pasta': ('grams', 100.0),
    'flour': ('grams', 120.0),
    'oats': ('grams', 90.0),

    # 🥛 Dairy
    'milk': ('liters', 0.24),
    'cheese': ('grams', 120.0),
    'butter': ('grams', 14.0),
    'yogurt': ('grams', 245.0),
    'cream': ('ml', 240.0),

    # 🐔 Proteins
    'chicken': ('grams', 140.0),
    'beef': ('grams', 150.0),
    'pork': ('grams', 150.0),
    'salmon': ('grams', 180.0),
    'salmon fillet': ('grams', 180.0),
    'egg': ('pieces', 1.0),
    'tofu': ('grams', 120.0),
    'block tofu': ('grams', 120.0),  # Added support for "1 block (12 oz) tofu"

    # 🧂 Pantry Items
    'sugar': ('grams', 200.0),
    'salt': ('grams', 300.0),
    'soy sauce': ('ml', 15.0),
    'oil': ('ml', 15.0),
    'olive oil': ('ml', 15.0),
    'vegetable oil': ('ml', 15.0),
    'vinegar': ('ml', 15.0),
    'tomato sauce': ('ml', 250.0),
    'canned beans': ('grams', 250.0),

    # 🍞 Bakery
    'bread': ('slices', 1.0),
    'buns': ('pieces', 1.0),
    'pizza dough': ('batches', 1.0),
    'flour tortillas': ('pieces', 1.0),

    # 🌶️ Spices
    'black pepper': ('grams', 2.3),
    'chili flakes': ('grams', 2.0),
    'italian seasoning': ('grams', 1.5),
    'cumin': ('grams', 2.0),
}


@app.route('/deduct-ingredients', methods=['POST'])
def deduct_ingredients():
    data = request.json
    used_ingredients = data.get('ingredients', [])

    if not used_ingredients:
        return jsonify({'error': 'No ingredients provided'}), 400

    try:
        conn = mysql.connector.connect(
            host="",
            user="",
            password="",
            database=""
        )
        cursor = conn.cursor()

        def normalize_words(text):
            descriptors = [
                'sliced', 'chopped', 'minced', 'shredded', 'grated',
                'cooked', 'drained', 'rinsed', 'frozen', 'diced',
                'small', 'large', 'to', 'taste', 'and'
            ]
            words = text.lower().replace(',', '').split()
            return [w for w in words if w not in descriptors]

        for full_line in used_ingredients:
            print(f"🧾 Processing: {full_line}")
            parts = full_line.lower().replace(",", "").split()

            if len(parts) < 3:
                print(f"⚠️ Skipping invalid format: {full_line}")
                continue

            try:
                qty = float(parts[0]) if '/' not in parts[0] else eval(parts[0])
            except Exception:
                print(f"⚠️ Invalid quantity: {parts[0]}")
                continue

            unit = parts[1]
            raw_item = ' '.join(parts[2:])
            item_tokens = normalize_words(raw_item)
            item_name = ' '.join(item_tokens)

            # 🔍 Try direct match
            matched_key = next((key for key in UNIT_CONVERSIONS if key in item_name), None)

            # 🔁 Fallback match using token
            if not matched_key:
                for token in item_tokens:
                    if token in UNIT_CONVERSIONS:
                        matched_key = token
                        print(f"🔄 Fallback match for '{item_name}' → using '{matched_key}'")
                        break

            if not matched_key:
                print(f"❌ No unit conversion found for: {item_name}")
                continue

            standard_unit, multiplier = UNIT_CONVERSIONS[matched_key]
            converted_qty = round(qty * multiplier, 2)

            cursor.execute("SELECT id, item, quantity_with_unit FROM ingredients")
            db_results = cursor.fetchall()

            found_match = False
            for ing_id, db_item, db_qty_str in db_results:
                db_tokens = normalize_words(db_item)

                if matched_key in db_tokens or any(token in db_tokens for token in item_tokens):
                    db_parts = db_qty_str.split()
                    if not db_parts or not db_parts[0].replace('.', '', 1).isdigit():
                        continue

                    db_qty = float(db_parts[0])
                    db_unit = db_parts[1] if len(db_parts) > 1 else standard_unit

                    new_qty = max(0, db_qty - converted_qty)

                    if new_qty == 0:
                        cursor.execute("DELETE FROM ingredients WHERE id = %s", (ing_id,))
                        print(f"🗑️ Deleted '{db_item}' from inventory (used up)")
                    else:
                        new_qty_str = f"{new_qty:.2f} {db_unit}"
                        cursor.execute(
                            "UPDATE ingredients SET quantity_with_unit = %s WHERE id = %s",
                            (new_qty_str, ing_id)
                        )
                        print(f"✅ Deducted {converted_qty} {standard_unit} from '{db_item}' → {new_qty_str}")

                    found_match = True
                    break

            if not found_match:
                print(f"❌ No DB match found for: {item_name} (converted {converted_qty} {standard_unit})")

        conn.commit()
        return jsonify({'message': 'Ingredients deducted successfully'}), 200

    except Exception as e:
        print("🔥 Error:", str(e))
        return jsonify({'error': str(e)}), 500

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
