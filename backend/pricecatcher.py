from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Set up Selenium WebDriver with Default Profile
options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")  # Open browser in full-screen
options.add_argument("--disable-gpu")  # Improve performance

# Add Chrome Profile Path (change this to your actual profile path)
options.add_argument(r"user-data-dir=C:\Users\ASUS\AppData\Local\Google\Chrome\User Data")
options.add_argument(r"profile-directory=Profile 3")  # Change profile if needed

# Initialize the driver with the default profile
driver = webdriver.Chrome(options=options)
driver.get("https://www.blinkit.com")  # Open Blinkit

try:
    # Wait until the search input field appears
    wait = WebDriverWait(driver, 10)

    # Find and click on the search box
    search_box = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "input[class*='SearchBarContainer__Input']")))
    search_box.click()

    # Refetch the search box after click
    search_box = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "input[class*='SearchBarContainer__Input']")))

    # Type "tomatoes" and search
    search_box.send_keys("tomatoes")
    search_box.send_keys(Keys.ENTER)

    # Wait for results to load
    wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "div[class*='Product__UpdatedPlpProductContainer']")))

    # Scrape product names and prices
    products = driver.find_elements(By.CSS_SELECTOR, "div[class*='Product__UpdatedPlpProductContainer']")

    product_data = []
    count = 0

    for product in products:
        if count >= 10:  # Stop after 10 products
            break

        try:
            # Get product name
            name = product.find_element(By.CSS_SELECTOR, "div[class*='Product__UpdatedTitle']").text
            # Get price
            price = product.find_element(By.CSS_SELECTOR, "div[class*='Product__UpdatedPriceAndAtcContainer'] div").text

            product_data.append((name, price))
            count += 1
        except Exception as e:
            print("Error extracting product data:", e)
            continue  # Skip if product data is not found

    # Print scraped data
    for idx, (name, price) in enumerate(product_data, 1):
        print(f"{idx}. {name} - {price}")

except Exception as e:
    print("An error occurred:", e)

finally:
    driver.quit()
