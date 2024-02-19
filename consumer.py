import re
from robocorp.tasks import task
from robocorp import workitems
from robocorp.workitems import Input

from SwagLabs import SwagLabs

swag_labs = SwagLabs()

@task
def load_and_process_all_orders():
    swag_labs.initialize()
    
    try:
        for item in workitems.inputs:
            load_and_process_order(item)
    except Exception as err:
        print(err)
        workitems.inputs.current.fail(
            exception_type='APPLICATION',
            code='UNCAUGHT_ERROR',
            message=str(err)
        )

def load_and_process_order(work_item: Input):
    name = work_item.payload['Name']
    zip_code = work_item.payload['Zip']
    items = work_item.payload['Items']
    
    try:
        swag_labs.process_order(name, zip_code, items)
        work_item.done()
    except Exception as err:
        handle_exceptions(err, work_item)

def handle_exceptions(err, work_item: Input):
    error_message = str(err)
    print(error_message)
    
    if "Application cannot be reset" in error_message:
        work_item.fail(
            exception_type='APPLICATION',
            code='WEBSITE_UNRESPONSIVE',
            message=error_message
        )
    elif "Shopping cart" in error_message:
        work_item.fail(
            exception_type='APPLICATION',
            code='CART_NOT_EMPTY',
            message=error_message
        )
    elif "Add product to cart" in error_message:
        item_causing_problem = re.findall(r'.*text\("([\w\s]+)"', error_message)[0]
        message = f"The requested item '{item_causing_problem}' could not be added to the cart. Check spelling and consider trying again."
        work_item.fail(
            exception_type='BUSINESS',
            code='ITEM_PROBLEM',
            message=message
        )
    elif "Order invalid" in error_message:
        work_item.fail(
            exception_type='BUSINESS',
            code='ORDER_INCOMPLETE',
            message=error_message
        )
    else:
        work_item.fail(
            exception_type='APPLICATION',
            code='UNCAUGHT_ERROR',
            message=error_message
        )