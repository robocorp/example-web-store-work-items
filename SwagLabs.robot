*** Settings ***
Library           String
Library           RPA.Browser.Selenium

*** Variables ***
${SWAG_LABS_URL}=       https://www.saucedemo.com
${SWAG_LABS_USER}=      standard_user
${SWAG_LABS_PASSWORD}=  secret_sauce

*** Keywords ***
Open Swag Labs
    Open Available Browser    ${SWAG_LABS_URL}

*** Keywords ***
Login
    Input Text        user-name    ${SWAG_LABS_USER}
    Input Password    password     ${SWAG_LABS_PASSWORD}
    Submit Form
    Assert logged in

*** Keywords ***
Process order
    [Arguments]    ${products}
    Reset application state
    Open products page
    Assert cart is empty
    FOR    ${product}    IN    @{products}
        Wait Until Keyword Succeeds    3x    1s    Add product to cart    ${product}
    END
    Wait Until Keyword Succeeds    3x    1s    Open cart
    Capture page screenshot    ${OUTPUTDIR}/cart.png
    Checkout    ${products[0]}

*** Keywords ***
Reset application state
    Click Button    css:.bm-burger-button button
    Click Element When Visible    id:reset_sidebar_link

*** Keywords ***
Open products page
    Go To    ${SWAG_LABS_URL}/inventory.html

*** Keywords ***
Add product to cart
    [Arguments]    ${order}
    ${product_name}=    Set Variable    ${order["Item"]}
    ${locator}=    Set Variable    xpath://div[@class="inventory_item" and descendant::div[contains(text(), "${product_name}")]]
    ${product}=    Get WebElement    ${locator}
    ${add_to_cart_button}=    Set Variable    ${product.find_element_by_class_name("btn_primary")}
    Click Button    ${add_to_cart_button}

*** Keywords ***
Open cart
    Click Link    css:.shopping_cart_link
    Assert cart page

*** Keywords ***
Checkout
    [Arguments]    ${order}
    ${name}  ${product}  ${zip}=    Set variable    ${order}
    Click Button    css:#checkout
    Assert checkout information page
    ${first_name}  ${last_name}=    Split string    ${name}
    Input Text    first-name    ${first_name}
    Input Text    last-name    ${last_name}
    Input Text    postal-code    ${zip}
    Submit Form
    Assert checkout confirmation page
    Click Element When Visible    css:#finish
    Assert checkout complete page

*** Keywords ***
Assert logged in
    Wait Until Page Contains Element    inventory_container
    Location Should Be    ${SWAG_LABS_URL}/inventory.html

*** Keywords ***
Assert cart page
    Wait Until Page Contains Element    cart_contents_container
    Location Should Be    ${SWAG_LABS_URL}/cart.html

*** Keywords ***
Assert cart badge
    [Arguments]    ${items}
    ${count}=    Get length    ${items}
    Element Text Should Be    css:.shopping_cart_badge    ${count}

*** Keywords ***
Assert cart is empty
    Element Text Should Be    css:.shopping_cart_link    ${EMPTY}
    Page Should Not Contain Element    css:.shopping_cart_badge

*** Keywords ***
Assert items in cart
    [Arguments]    ${items}
    ${count_items}=    Get length    ${items}
    ${count_cart}=     Get element count    css:.cart_item

*** Keywords ***
Assert checkout information page
    Wait Until Page Contains Element    checkout_info_container
    Location Should Be    ${SWAG_LABS_URL}/checkout-step-one.html

*** Keywords ***
Assert checkout confirmation page
    Wait Until Page Contains Element    checkout_summary_container
    Location Should Be    ${SWAG_LABS_URL}/checkout-step-two.html

*** Keywords ***
Assert checkout complete page
    Wait Until Page Contains Element    checkout_complete_container
    Location Should Be    ${SWAG_LABS_URL}/checkout-complete.html
