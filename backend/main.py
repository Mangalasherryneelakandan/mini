from fastapi import FastAPI
import requests
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("serviceAccountKey.json")  # Replace with your Firebase credentials
firebase_admin.initialize_app(cred)
db = firestore.client()

# Create API instance
app = FastAPI()

# Web Scraping Function
def scrape_recipe(url):
    headers = {"User-Agent": "Mozilla/5.0"}
    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.text, "html.parser")

    title = soup.find("h1").text if soup.find("h1") else "No Title"
    ingredients = [i.text for i in soup.find_all(class_="ingredient")]  # Adjust class names as needed
    steps = [s.text for s in soup.find_all(class_="step")]

    return {"title": title, "ingredients": ingredients, "steps": steps}

# API Endpoint to Fetch Recipes
@app.get("/scrape/")
def get_recipe(url: str):
    recipe = scrape_recipe(url)

    # Save to Firestore
    db.collection("recipes").add(recipe)

    return {"message": "Recipe saved!", "recipe": recipe}

