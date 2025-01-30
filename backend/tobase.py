import requests
from bs4 import BeautifulSoup
from google.cloud import language_v1
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")  # Replace with your Firebase service account key
firebase_admin.initialize_app(cred)

# Get Firestore client
db = firestore.client()

# Initialize Google NLP client
client = language_v1.LanguageServiceClient()

# Function to structure data using Google NLP
def structure_data_using_google_nlp(raw_data):
    document = language_v1.Document(
        content=raw_data['name'] + "\n" + raw_data['ingredients'] + "\n" + raw_data['instructions'],
        type_=language_v1.Document.Type.PLAIN_TEXT
    )

    # Use Google NLP to analyze the document
    response = client.analyze_entities(document=document)

    # Extract structured information (simple example)
    entities = [entity.name for entity in response.entities]
    structured_data = {
        'name': raw_data['name'],
        'ingredients': raw_data['ingredients'],
        'instructions': raw_data['instructions'],
        'entities': entities  # Extracted entities
    }

    return structured_data

# Function to scrape the website and get data
def scrape_recipes(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')

    recipes = []

    # Example scraping logic (adjust according to the website structure)
    for recipe in soup.find_all('div', class_='recipe'):
        raw_name = recipe.find('h2').text.strip()  # Recipe name in <h2> tag
        raw_ingredients = recipe.find('ul', class_='ingredients').text.strip()  # Ingredients in <ul> tag
        raw_instructions = recipe.find('p', class_='instructions').text.strip()  # Instructions in <p> tag

        # Raw data that needs structuring
        raw_data = {
            "name": raw_name,
            "ingredients": raw_ingredients,
            "instructions": raw_instructions
        }

        # Use Google NLP to structure the raw data
        structured_recipe = structure_data_using_google_nlp(raw_data)
        recipes.append(structured_recipe)

    return recipes

# URL of the website you want to scrape
url = 'https://example.com/recipes'  # Replace with the actual URL

# Scrape the website and structure the data
scraped_recipes = scrape_recipes(url)

# Insert structured data into Firestore
for recipe in scraped_recipes:
    doc_ref = db.collection("recipes").document()  # Auto-generate document ID
    doc_ref.set({
        "name": recipe['name'],
        "ingredients": recipe['ingredients'],
        "instructions": recipe['instructions'],
        "entities": recipe['entities']  # Store the structured entities
    })

print("Data successfully inserted into Firestore!")
