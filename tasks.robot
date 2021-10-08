*** Settings ***
Library           RPA.Robocorp.WorkItems
Library           RPA.Excel.Files
Library           RPA.Tables
Resource          SwagLabs.robot

*** Variables ***
${ORDER_FILE_NAME}=    orders.xlsx

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
Split orders file
    [Documentation]    Read orders file from input item and split into outputs
    Get work item file    ${ORDER_FILE_NAME}
    Open workbook    ${ORDER_FILE_NAME}
    ${table}=    Read worksheet as table    header=True
    ${groups}=    Group table by column    ${table}    Name
    FOR    ${products}    IN    @{groups}
        Create Output Work Item
        ${rows}=    Export table    ${products}
        Set work item variable    products    ${rows}
        Save Work Item
    END

*** Tasks ***
Load and Process All Orders
    [Documentation]    Order all products in input item queue
    Open Swag Labs
    Wait until keyword succeeds    3x    1s    Login
    For each input work item    Load and Process Order
    [Teardown]    Close browser