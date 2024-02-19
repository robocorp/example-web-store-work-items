import time
from robocorp import browser

class SwagLabs:
    def __init__(self) -> None:
        self.swag_labs_url = "https://www.saucedemo.com"
        self.swag_labs_user = "standard_user"
        self.swag_labs_password = "secret_sauce"
        self.page: browser.Page

        browser.configure(screenshot="only-on-failure", headless=False)

    def initialize(self):
        try:
            self.open_swag_labs()
            wait_until_keyword_succeeds(3, 1, self.login)

        except Exception as err:
            if str(err) == "Website unavailable":
                print(f"Website unavailable error: {err}")
                raise Exception(
                    "Bot could not Initialize due to website unavailability"
                )

            elif str(err) == "Login failed":
                print(f"Login failed error: {err}")
                raise Exception("Bot could not Initialize due to login failure")

            else:
                print(f"An unexpected error occurred: {err}")

    def open_swag_labs(self):
        browser.goto(url=self.swag_labs_url)

    def login(self):
        self.page = browser.page()
        self.page.fill("#user-name", self.swag_labs_user)
        self.page.fill("#password", self.swag_labs_password)
        self.page.click("input:text('Login')")

    def process_order(self, name, zip_code, items):
        self.reset_application_state()
        self.open_products_page()
        for item in items:
            # Utilizing this function helps ensure the robot can succeed in the action.
            wait_until_keyword_succeeds(3, 1, self.add_product_to_cart, item)
        wait_until_keyword_succeeds(3, 1, self.open_cart)
        browser.screenshot()
        self.checkout(name, zip_code)

    def reset_application_state(self):
        self.page.locator(".bm-burger-button button").click()
        self.page.locator("#reset_sidebar_link").click()

    def open_products_page(self):
        browser.goto(f"{self.swag_labs_url}/inventory.html")

    def add_product_to_cart(self, product_name: str):
        locator = f"//div[contains(@class, 'inventory_item') and descendant::div[contains(text(), '{product_name}')]]"
        self.page.locator(locator).locator(".btn_primary").click()

    def open_cart(self):
        self.page.locator(".shopping_cart_link").click()

    def checkout(self, name, zip_code):
        self.page.locator("#checkout").click()
        first_name, last_name = name.split(" ")

        self.page.fill("#first-name", first_name)
        self.page.fill("#last-name", last_name)
        self.page.fill("#postal-code", str(zip_code))
        self.page.locator("#continue").click()
        self.page.locator("#finish").click()



def wait_until_keyword_succeeds(retries: int, interval: int, function, *args):
    for _ in range(retries):
        try:
            function(*args)
            return
        except Exception as e:
            time.sleep(interval)
    raise Exception(
        f"Keyword '{function.__name__}' did not succeed after {retries} attempts with these args:[{args}]"
    )