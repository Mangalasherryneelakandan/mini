import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Initialize Firebase Admin SDK
def initialize_firebase(credential_path):
    """Initializes Firebase Admin SDK using credentials from a specified path."""
    try:
        cred = credentials.Certificate(credential_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Firebase initialized successfully.")
        return db
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        return None

def display_data(db, collection_name):
    """
    Fetches and displays all documents from a specified Firestore collection.

    Args:
        db:  Firestore client object.
        collection_name: The name of the Firestore collection to retrieve data from.
    """
    try:
        docs = db.collection(collection_name).get()
        if not docs:
            print(f"No documents found in collection: {collection_name}")
            return

        print(f"Data from collection: {collection_name}\n")
        for doc in docs:
            print(f"Document ID: {doc.id}")
            doc_data = doc.to_dict()  # Convert DocumentSnapshot to a dictionary
            for key, value in doc_data.items():
                print(f"  {key}: {value}")  # Print key-value pairs
            print("-" * 20)  # Separator between documents

    except Exception as e:
        print(f"Error fetching data: {e}")

if __name__ == "__main__":
    # **WARNING:** Hardcoding credentials is INSECURE.  Use environment variables if possible.
    credential_path = "serviceAccountKey.json"  # Replace with your actual path

    db = initialize_firebase(credential_path)  # Initialize Firebase with the path

    if db:
        collection_name = "scraped_data"  # Replace with your collection name
        display_data(db, collection_name)
    else:
        print("Failed to initialize Firebase.  Check your credentials.")