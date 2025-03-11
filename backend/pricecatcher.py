from flask import Flask, jsonify, request
import csv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

app = Flask(__name__)

class BlinkitScraper:
    def __init__(self):
        options = webdriver.ChromeOptions()
        options.add_argument("--start-maximized")
        options.add_argument("--disable-gpu")
        options.add_argument(r"user-data-dir=C:\Users\ASUS\AppData\Local\Google\Chrome\User Data")
        options.add_argument(r"profile-directory=Profile 3")
        self.driver = webdriver.Chrome(options=options)

    def scrape(self, query):
        search_url = f"https://blinkit.com/s/?q={query}"
        self.driver.get(search_url)
        try:
            wait = WebDriverWait(self.driver, 10)
            wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "div[class*='Product__UpdatedPlpProductContainer']")))

            products = self.driver.find_elements(By.CSS_SELECTOR, "div[class*='Product__UpdatedPlpProductContainer']")
            product_data = []
            count = 0
            for product in products:
                if count >= 15:
                    break
                try:
                    name = product.find_element(By.CSS_SELECTOR, "div[class*='Product__UpdatedTitle']").text
                    price = product.find_element(By.CSS_SELECTOR, "div[class*='Product__UpdatedPriceAndAtcContainer'] div").text
                    image = product.find_element(By.CSS_SELECTOR, "img").get_attribute("src")
                    product_data.append({"name": name, "price": price, "image": image})
                    count += 1
                except Exception as e:
                    print(f"Error extracting product data: {e}")
                    continue

            # Save data to CSV
            with open("blinkit_products.csv", mode="w", newline="", encoding="utf-8") as file:
                writer = csv.writer(file)
                writer.writerow(["Product Name", "Price", "Image URL"])  # CSV header
                for item in product_data:
                    writer.writerow([item["name"], item["price"], item["image"]])

            print("Data saved to blinkit_products.csv")
            return product_data
        except Exception as e:
            print(f"An error occurred: {e}")
            return f"Error: {e}"
        finally:
            self.driver.quit()


@app.route('/scrape', methods=['GET'])
def scrape_data():
    query = request.args.get('query', '')
    if not query:
        return jsonify({"message": "Query parameter is required!"}), 400

    scraper = BlinkitScraper()
    result = scraper.scrape(query)

    # Return the scraped products as a JSON response
    if isinstance(result, list):
        return jsonify({"products": result, "message": "Data scraped successfully"})
    else:
        return jsonify({"message": result}), 500


if __name__ == '__main__':
    app.run(debug=True)
