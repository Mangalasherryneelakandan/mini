import requests
from bs4 import BeautifulSoup
import google.generativeai as genai
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# ----- CONFIGURATION -----

# Gemini AI API Key
GEMINI_API_KEY = "AIzaSyDpt626QWrqXg6OJmlGOBhOR-qZET2STbI"  # Replace with your actual API key

# Firebase Credentials (download your service account key file)
FIREBASE_CREDENTIALS_PATH = "serviceAccountKey.json"  # Replace with the correct path

# Web Scraping Target
TARGET_URL = "https://paleoleap.com/almond-banana-cinnamon-smoothie/"  # Replace with the actual URL you want to scrape

# Firebase Collection Name
FIREBASE_COLLECTION = "scraped_data"  # The name of the collection to store data in

# --------------------------

def initialize_gemini():
    """Initializes the Gemini AI API."""
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel('gemini-pro')  # or 'gemini-pro-vision' if you need image support
    return model


def initialize_firebase():
    """Initializes the Firebase app."""
    cred = credentials.Certificate(FIREBASE_CREDENTIALS_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    return db


def scrape_website(url):
    """Scrapes the specified URL and returns the text content."""
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raise HTTPError for bad responses (4xx or 5xx)
        soup = BeautifulSoup(response.content, 'html.parser')

        # Extract relevant text.  Adapt this to your target website.
        # This example extracts all the text inside <p> tags.  You might need to
        # use different selectors (e.g., div, article, span, class names)
        text_content = ' '.join([p.text for p in soup.find_all('p')])  # Concatenate paragraphs

        return text_content
    except requests.exceptions.RequestException as e:
        print(f"Error during web scraping: {e}")
        return None  # Or raise the exception if you want the program to stop.
    except Exception as e:
        print(f"Error during web scraping (BeautifulSoup): {e}")
        return None


def summarize_with_gemini(text, prompt_instructions="Summarize the following text in a concise and informative way, identifying the key points and main topics:", max_output_tokens=500):
    """Summarizes the given text using Gemini AI."""
    model = genai.GenerativeModel('gemini-pro')

    if not text:
        print("No text to summarize.")
        return None

    prompt = f"{prompt_instructions}\n\n{text}"

    try:
        response = model.generate_content(prompt, generation_config=genai.GenerationConfig(max_output_tokens=max_output_tokens))
        return response.text
    except Exception as e:
        print(f"Error during Gemini API call: {e}")
        return None


def extract_information_with_gemini(text, information_request="Identify the key entities, locations, organizations, people, and events mentioned in the text.  Return as a structured summary.", max_output_tokens=800):
    """Extracts important information from the text using Gemini AI.  You can customize the information_request."""
    model = genai.GenerativeModel('gemini-pro')  # Or 'gemini-pro-vision'

    if not text:
        print("No text to extract information from.")
        return None

    prompt = f"{information_request}\n\n{text}"

    try:
        response = model.generate_content(prompt, generation_config=genai.GenerationConfig(max_output_tokens=max_output_tokens))
        return response.text
    except Exception as e:
        print(f"Error during Gemini API call: {e}")
        return None


def store_in_firebase(db, data):
    """Stores the data in a Firebase Firestore collection."""
    try:
        db.collection(FIREBASE_COLLECTION).add(data)
        print("Data successfully stored in Firebase.")
    except Exception as e:
        print(f"Error storing data in Firebase: {e}")


def main():
    """Main function to orchestrate the scraping, AI processing, and storage."""
    print("Initializing...")
    gemini_model = initialize_gemini()
    db = initialize_firebase()

    print("Scraping website...")
    scraped_text = scrape_website(TARGET_URL)

    if scraped_text:
        print("Summarizing with Gemini...")
        summary = summarize_with_gemini(scraped_text)

        print("Extracting key information with Gemini...")
        extracted_info = extract_information_with_gemini(scraped_text)

        if summary and extracted_info:
            data_to_store = {
                "original_text": scraped_text,
                "summary": summary,
                "extracted_information": extracted_info,
                "source_url": TARGET_URL,
                "timestamp": firestore.SERVER_TIMESTAMP  # Adds a timestamp for when the data was stored
            }

            print("Storing data in Firebase...")
            store_in_firebase(db, data_to_store)
        else:
            print("Failed to summarize or extract information.  Check Gemini API output.")
    else:
        print("Failed to scrape website.  Check the URL and connection.")

    print("Finished.")


if __name__ == "__main__":
    main()