*** Settings ***
Library     RPA.Robocorp.WorkItems
Library     RPA.Tables
Resource    SwagLabs.robot


*** Tasks ***
Load and Process All Orders
    [Documentation]    Order all products in input item queue
    Open Swag Labs
    Wait Until Keyword Succeeds    3x    1s    Login
    For Each Input Work Item    Load and Process Order
    [Teardown]    Close browser


*** Keywords ***
Load and Process Order
    [Documentation]    Order all products in one work item products list
    ${payload}=    Get Work Item Payload
    ${name}=    Set Variable    ${payload}[Name]
    ${zip}=    Set Variable    ${payload}[Zip]
    ${items}=    Set Variable    ${payload}[Items]
    TRY
        Process order    ${name}    ${zip}    ${items}
        Release Input Work Item    DONE
    EXCEPT
        Log    Order prosessing failed for: ${name} zip: ${zip} items: ${items}    level=ERROR
        Release Input Work Item
        ...    state=FAILED
        ...    exception_type=BUSINESS
        ...    message=Order prosessing failed for: ${name}
    END
