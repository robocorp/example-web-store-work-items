*** Settings ***
Library           RPA.Robocorp.WorkItems
Library           RPA.Excel.Files
Library           RPA.Tables

*** Variables ***
${ORDER_FILE_NAME}=    orders.xlsx

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
