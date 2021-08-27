# Web store order processor: multiple work items example

From an incoming Excel file this robot will split orders by customer, which are then handled individually and in parallel.

It demonstrates the Work Items feature of Robocorp Control Room:

- Triggering a process with custom payloads
- Passing data and files between process steps
- Parallel execution of steps

## Tasks

The robot is split into two tasks, meant to be run as separate steps.

The first task will:

- Read an Excel file from the work item
- Split it into orders based on the customer
- Create a new work item for each order

The second task will:

- Read the products in the order from the work item
- Log-in to the web store
- Order all products

## Excel input file

The first task expects an Excel file in a certain format. An example file with the correct format can be seen in [`orders.xlsx`](./devdata/orders.xlsx).

## Local development

When running in **Control Room**, the work items will be automatically managed and passed between steps in the process. However, when running locally the work items can be simulated using a JSON-based file.

The ``RPA.Robocorp.WorkItems`` library can be controlled with specific environment variables, as seen in the [`env.json`](./devdata/env.json) file.

This example also includes two example inputs for both tasks in the process, called [`items1.json`](./devdata/items1.json) and [`items2.json`](./devdata/items2.json). Depending on which task is being developed, different work item files can be used.

## Control room setup

To see how to set up Control Room and understand more about how work items are used, see the following article: [Using work items](https://robocorp.com/docs/development-guide/control-room/data-pipeline).
