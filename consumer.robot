*** Settings ***
Library           RPA.Robocorp.WorkItems
Library           RPA.Tables
Resource          SwagLabs.robot

*** Keywords ***
Load and Process Order
    [Documentation]    Order all products in one work item products list
    ${payload}=    Get Work Item Payload
    ${rows}=    Set Variable    ${payload}[products]
    ${products}=    Create table    ${rows}
    ${passed}   Run Keyword And Return Status    Process order    ${products}
    IF     ${passed}
        Release input work item    DONE
    ELSE
        Log    Order prosessing failed for: ${rows}   level=ERROR
        Release input work item    FAILED
    END

*** Tasks ***
Load and Process All Orders
    [Documentation]    Order all products in input item queue
    Open Swag Labs
    Wait until keyword succeeds    3x    1s    Login
    For Each Input Work Item    Load and Process Order
    [Teardown]    Close browser

