*** Settings ***
Library           Collections
Library           RPA.Robocorp.WorkItems
Library           RPA.Excel.Files
Library           RPA.Tables

*** Variables ***
${ORDER_FILE_NAME}=    orders.xlsx

*** Tasks ***
Split orders file
    [Documentation]    Read orders file from input item and split into outputs
    Get Work Item File    ${ORDER_FILE_NAME}
    Open Workbook    ${ORDER_FILE_NAME}
    ${table}=    Read Worksheet As Table    header=True
    ${groups}=    Group Table By Column    ${table}    Name
    FOR    ${products}    IN    @{groups}
        Create Output Work Item
        ${rows}=    Export Table    ${products}
        @{items}=    Create List
        FOR    ${row}    IN    @{rows}
            ${name}=    Set Variable    ${row}[Name]
            ${zip}=    Set Variable    ${row}[Zip]
            Append To List    ${items}    ${row}[Item]
        END
        Set Work Item Variable    Name    ${name}
        Set Work Item Variable    Zip    ${zip}
        Set Work Item Variable    Items    ${items}
        Save Work Item
    END
