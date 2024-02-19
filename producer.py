from typing import List

from robocorp import excel, workitems
from robocorp.tasks import task
from robocorp.excel.tables import Table

ORDER_FILE_NAME = 'orders.xlsx'

@task
def split_orders_file():
    """
    Read orders file from input item and split into outputs
    """
    
    item = workitems.inputs.current
    path = item.get_file(ORDER_FILE_NAME)

    # Open the workbook and read the worksheet as a table
    workbook = excel.open_workbook(path)
    worksheet = workbook.worksheet("Taul1")
    table = worksheet.as_table(header=True)

    # Group the table by the 'Name' column
    groups: List[Table] = table.group_by_column('Name')

    for products in groups:
        rows: List[dict] = products.to_list()
        for row in rows:
            workitems.outputs.create(payload=row)