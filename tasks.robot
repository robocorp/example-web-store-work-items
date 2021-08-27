*** Settings ***
Library     RPA.Robocorp.WorkItems
Library     RPA.Excel.Files
Library     RPA.Tables
Resource    SwagLabs.robot

*** Variables ***
${ORDER_FILE_NAME}=     orders.xlsx

*** Tasks ***
Split orders file
    [Documentation]    Read orders file from input item and split into outputs
    Get work item file  ${ORDER_FILE_NAME}
    Open workbook       ${ORDER_FILE_NAME}
    ${table}=   Read worksheet as table     header=True
    ${groups}=  Group table by column    ${table}    Name
    FOR    ${products}    IN    @{groups}
        Create output work item
        ${rows}=    Export table   ${products}
        Set work item variable    products    ${rows}
        Save work item
    END

Process order
    [Documentation]    Order all products in input item
    ${rows}=        Get work item variable    products
    ${products}=    Create table    ${rows}
    Open Swag Labs
    Wait until keyword succeeds    3x    1s    Login
    Process order   ${products}
    [Teardown]      Close browser
