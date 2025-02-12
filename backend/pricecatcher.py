import scrapy
import csv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

class BlinkitScraper:
    def __init__(self):
        options = webdriver.ChromeOptions()
        options.add_argument("--start-maximized")
        options.add_argument("--disable-gpu")
        options.add_argument(r"user-data-dir=C:\Users\ASUS\AppData\Local\Google\Chrome\User Data")
        options.add_argument(r"profile-directory=Profile 3")
        self.driver = webdriver.Chrome(options=options)

    def scrape(self):
        self.driver.get("https://blinkit.com/cn/fresh-vegetables/cid/1487/1489")
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
                writer.writerow(["Product Name", "Price", "Image URL"])
                for item in product_data:
                    writer.writerow([item["name"], item["price"], item["image"]])

            print("Data saved to blinkit_products.csv")
        except Exception as e:
            print(f"An error occurred: {e}")
        finally:
            self.driver.quit()

if __name__ == "__main__":
    scraper = BlinkitScraper()
    scraper.scrape()
