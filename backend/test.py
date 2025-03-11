import requests

def search_by_ingredient(ingredient):
    url = f"https://www.themealdb.com/api/json/v1/1/filter.php?i={ingredient}"
    response = requests.get(url)

    # Check if the response is valid
    if response.status_code == 200:
        data = response.json()
        if data["meals"]:
            return data["meals"]  # Returns a list of recipes using this ingredient
        else:
            return "No recipes found for this ingredient."
    else:
        return f"Error: Unable to fetch data. Status Code: {response.status_code}"

# Example usage
recipes = search_by_ingredient("Chicken")
print(recipes)  # Shows all recipes containing chicken
