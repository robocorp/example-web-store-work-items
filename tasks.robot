*** Settings ***
Library           RPA.Robocorp.WorkItems
Library           RPA.Excel.Files
Library           RPA.Tables
Resource          SwagLabs.robot

*** Variables ***
${ORDER_FILE_NAME}=    orders.xlsx

*** Keywords ***
Process order
    [Documentation]    Order all products in one work item products list
    ${payload}=    Get Work Item Payload
    Log    ${payload}
    ${rows}=    Set Variable    ${payload}[${products}]
    Log    ${rows}
    ${products}=    Create table    ${rows}
    Open Swag Labs
    Wait until keyword succeeds    3x    1s    Login
    Process order    ${products}

Process Work Item
    ${status}    ${return}    Run Keyword And Ignore Error    Process order
    IF    "${status}" == "FAIL"
        Log
        ...    Process order error: ${return}
        ...    level=ERROR
        Release input work item    FAILED
    ELSE
        Release input work item    DONE
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
Process order
    [Documentation]    Order all products in input item queue
    For each input work item    Process Work Item
    [Teardown]    Close browser