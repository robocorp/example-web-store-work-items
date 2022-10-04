*** Settings ***
Library     String
Library     RPA.Browser.Selenium
Library     RPA.Robocorp.WorkItems


*** Variables ***
${SWAG_LABS_URL}=           https://www.saucedemo.com
# Username and password should be stored in the Control Room Vault normally.
${SWAG_LABS_USER}=          standard_user
${SWAG_LABS_PASSWORD}=      secret_sauce
# Used to turn on mocked demo failures if set in the robot.yaml
${FAIL}=                    ${False}


*** Keywords ***
Initialize Swag Labs
    [Documentation]    Logs into Swag Labs and confirms app is ready for input
    TRY
        Open Swag Labs
        Wait Until Keyword Succeeds    3x    1s    Login
    EXCEPT    Website unavailable    AS    ${err}
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=WEBSITE_DOWN
        ...    message=${err}
        Fail    Bot could not Initialize
    EXCEPT    Login failed    AS    ${err}
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=LOGIN_FAILURE
        ...    message=${err}
        Fail    Bot could not Initialize
    END

Open Swag Labs
    [Documentation]    Opens a new browser and navigates to web app.
    Open Available Browser    ${SWAG_LABS_URL}
    Induce random error    0.2    Website unavailable

Login
    [Documentation]    Logs into Swag Labs and confirms app is ready for input
    Induce random error    0.5    Login failed
    Input Text    user-name    ${SWAG_LABS_USER}
    Input Password    password    ${SWAG_LABS_PASSWORD}
    Submit Form
    Assert logged in

Process order
    [Documentation]    Processes the order from the work item.
    [Arguments]    ${name}    ${zip}    ${items}
    Reset application state
    Open products page
    Assert cart is empty
    FOR    ${item}    IN    @{items}
        # Utilizing this keyword helps ensure the robot can succeed
        # in the action.
        Wait Until Keyword Succeeds    3x    1s    Add product to cart    ${item}
    END
    Wait Until Keyword Succeeds    3x    1s    Open cart
    Capture page screenshot    ${OUTPUTDIR}/cart.png
    Checkout    ${name}    ${zip}

Reset application state
    Click Button    css:.bm-burger-button button
    Click Element When Visible    id:reset_sidebar_link
    Induce random error    0.2    Application cannot be reset

Open products page
    Go To    ${SWAG_LABS_URL}/inventory.html

Add product to cart
    [Arguments]    ${product_name}
    ${locator}=    Set Variable
    ...    xpath://div[@class="inventory_item" and descendant::div[contains(text(), "${product_name}")]]
    ${add_to_cart_button}=    Get WebElement    ${locator} >> class:btn_primary
    Click Button    ${add_to_cart_button}

Open cart
    Click Link    css:.shopping_cart_link
    Assert cart page

Checkout
    [Arguments]    ${name}    ${zip}
    Click Button    css:#checkout
    Assert checkout information page
    ${first_name}    ${last_name}=    Split string    ${name}
    Input Text    first-name    ${first_name}
    Input Text    last-name    ${last_name}
    Input Text    postal-code    ${zip}
    Submit Form
    Assert checkout confirmation page
    Induce random error    0.2    Order invalid
    Click Element When Visible    css:#finish
    Assert checkout complete page

Assert logged in
    [Documentation]    Checks if login was successful
    Wait Until Page Contains Element    inventory_container
    Location Should Be    ${SWAG_LABS_URL}/inventory.html

Assert cart page
    Wait Until Page Contains Element    cart_contents_container
    Location Should Be    ${SWAG_LABS_URL}/cart.html

Assert cart badge
    [Arguments]    ${items}
    ${count}=    Get length    ${items}
    Element Text Should Be    css:.shopping_cart_badge    ${count}

Assert cart is empty
    Element Text Should Be    css:.shopping_cart_link    ${EMPTY}
    Page Should Not Contain Element    css:.shopping_cart_badge
    Induce random error    0.2    Shopping cart not empty

Assert items in cart
    [Arguments]    ${items}
    ${count_items}=    Get length    ${items}
    ${count_cart}=    Get element count    css:.cart_item

Assert checkout information page
    Wait Until Page Contains Element    checkout_info_container
    Location Should Be    ${SWAG_LABS_URL}/checkout-step-one.html

Assert checkout confirmation page
    Wait Until Page Contains Element    checkout_summary_container
    Location Should Be    ${SWAG_LABS_URL}/checkout-step-two.html

Assert checkout complete page
    Wait Until Page Contains Element    checkout_complete_container
    Location Should Be    ${SWAG_LABS_URL}/checkout-complete.html

Induce random error
    [Documentation]
    ...    Causes a random error returning the provided message if the
    ...    global variable `FAIL` is set to `True`.
    ...
    ...    NOTE: This keyword should not be used in a production system.
    [Arguments]    ${failure_chance}=${0.2}    ${message}=Random failure
    IF    ${FAIL}
        IF    ${failure_chance} >= 1 or ${failure_chance} <= 0
            Log    Invalid failure_chance, resetting to default of 0.2.    level=WARN
            ${failure_chance}=    Set variable    ${0.2}
        END
        ${failures}=    Evaluate    round(${failure_chance} * 100)
        ${roll}=    Evaluate    random.randint(1,100)
        IF    ${roll} <= ${failures}    Fail    ${message}
    ELSE
        Log    Mocked errors are turned off.
    END
