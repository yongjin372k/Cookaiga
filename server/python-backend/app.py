from flask import Flask, request, jsonify
import mysql.connector
import openai
from openai import AzureOpenAI
from flask_cors import CORS

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
    
    # prompt = f"""
    #     Create simple and healthy recipes using the following ingredients: {ingredients}.
    #     Please include:
    #     1. Clear and easy-to-follow steps for each recipe, with each step focused on one or two ingredients at a time.
    #     2. Start by showing how to **cut or prepare** each ingredient (for example: "Chop the tomatoes into small cubes," or "Slice the chicken into thin strips").
    #     3. Simple measurements for each ingredient (for example: 1 cup, 2 teaspoons).
    #     4. Cooking times and temperatures for each step (for example: "Cook for 10 minutes on medium heat").
    #     5. Tips to make the recipe healthier (like using less oil, or swapping ingredients for healthier options).
    #     6. How many servings the recipe makes and any basic nutrition facts.
    #     7. Short and clear descriptions of cooking methods (like chopping, boiling, frying, etc.), especially for those unfamiliar with cooking.
    #     8. Options for ingredient substitutes (for example: dairy-free or gluten-free options).
    #     """

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
    recipe = response.choices[0].text.strip()
    return jsonify({"recipe": recipe})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
