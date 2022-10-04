*** Settings ***
Library     RPA.Robocorp.WorkItems
Library     RPA.Tables
Resource    SwagLabs.robot


*** Tasks ***
Load and Process All Orders
    [Documentation]    Order all products in input item queue
    [Setup]    Initialize Swag Labs
    TRY
        For Each Input Work Item    Load and Process Order
    EXCEPT    AS    ${err}
        # This is the general error handler that will release the error
        # to the control room as received from the code.
        #
        # If this is called after a lower level error has already
        # released the work item, the `Release input work item` keyword
        # will fail, producing a non-continuable failure (but not necessarily
        # a failure for the previously released work item). This failure will
        # force this instance of the robot to close and the Control Room
        # will start up a new run of the bot to continue processing other
        # work items.
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=UNCAUGHT_ERROR
        ...    message=${err}
    END
    [Teardown]    Close browser


*** Keywords ***
Load and Process Order
    [Documentation]    Order all products in one work item products list
    ${work_item}=    Get work item variables
    ${name}=    Set Variable    ${work_item}[Name]
    ${zip}=    Set Variable    ${work_item}[Zip]
    ${items}=    Set Variable    ${work_item}[Items]
    TRY
        Process order    ${name}    ${zip}    ${items}
        Release Input Work Item    DONE
    EXCEPT    Application cannot be reset
    ...    *react-burger-menu-btn*is not clickable*    type=GLOB    AS    ${err}
        # Catching different errors with search strings allows the robot to
        # release them to CR with different error codes for easy sorting,
        # troubleshooting, and retrying. Normally, you would try to
        # program error handling into the bot so it could work through
        # common errors encountered during execution.
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=WEBSITE_UNRESPONSIVE
        ...    message=${err}
    EXCEPT    Shopping cart    type=START    AS    ${err}
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    code=CART_NOT_EMPTY
        ...    message=${err}
    EXCEPT    *Add product to cart*failed*    type=GLOB    AS    ${err}
        Log    ${err}    level=ERROR
        # You can manipulate the error to
        # extract relevant information.
        ${item_causing_problem}=    Get regexp matches    ${err}    .*text\\(\\), "([\\w\\s]+)"    1
        ${message}=    Catenate
        ...    The requested item '${item_causing_problem}[0]' could not be added to the cart.
        ...    Check spelling and consider trying again.
        Release input work item
        ...    state=FAILED
        ...    exception_type=BUSINESS
        ...    code=ITEM_PROBLEM
        ...    message=${message}
    EXCEPT    Order invalid    AS    ${err}
        Log    ${err}    level=ERROR
        Release input work item
        ...    state=FAILED
        ...    exception_type=BUSINESS
        ...    code=ORDER_INCOMPLETE
        ...    message=${err}
    END
