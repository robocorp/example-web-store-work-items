# Web store order processor: multiple work items example

This robot splits orders by customer from an incoming Excel file. The orders are then handled individually and in parallel.

The robot demonstrates the Work Items feature of Robocorp Control Room:

- Triggering a process with custom payloads (input)
- Passing data and files between process steps
- Parallel execution of steps

> We recommended checking out the article "[Using work items](https://robocorp.com/docs/development-guide/control-room/data-pipeline)" before diving in.

## Tasks

The robot is split into two tasks, meant to run as separate steps. The first task generates (produces) data, and the second one reads (consumes) and processes that data.

> [Producer-consumer](https://en.wikipedia.org/wiki/Producer%E2%80%93consumer_problem), Wikipedia.

### The first task (the producer)

- Reads an Excel file from the work item
- Splits it into orders by customer
- Creates a new work item for each order

### The second task (the consumer)

- Logs in to the web store
- Reads the products in the order from the work item
  - Loops through work items to avoid time spent logging in per each work item.
- Orders the products

## Excel input file

The first task expects an [Excel file](https://github.com/robocorp/example-web-store-work-items/raw/master/devdata/orders.xlsx) in a specific format:

| Name          | Item                     | Zip  |
| ------------- | ------------------------ | ---- |
| Sol Heaton    | Sauce Labs Bolt T-Shirt  | 3695 |
| Gregg Arroyo  | Sauce Labs Onesie        | 4418 |
| Zoya Roche    | Sauce Labs Bolt T-Shirt  | 3013 |
| Gregg Arroyo  | Sauce Labs Bolt T-Shirt  | 4418 |
| Camden Martin | Sauce Labs Bolt T-Shirt  | 1196 |
| Zoya Roche    | Sauce Labs Fleece Jacket | 3013 |
| Zoya Roche    | Sauce Labs Onesie        | 3013 |
| Sol Heaton    | Sauce Labs Fleece Jacket | 3695 |
| Sol Heaton    | Sauce Labs Onesee        | 3695 |

# Local development

When running in **Control Room**, the work items will be automatically managed and passed between steps in the process. However, when running locally, the work items can be simulated using folder structure and JSON files.

## VsCode
[Robocorp VsCode extensions](https://robocorp.com/docs/developer-tools/visual-studio-code/overview) has built-in support making the use and testing of work items more straightforward.

> Note: This requires the use of [rpaframework v11.4.0](https://rpaframework.org/releasenotes.html) or later in your robot.

Using VsCode, you should only need [this guide](https://robocorp.com/docs/developer-tools/visual-studio-code/extension-features#using-work-items)


## Robocorp Lab and RCC from CLI

As each task in the robot expects different work item input, we need a way to control this.

This example includes test inputs, one for each task in the process:
- For task `Split orders file`:
  - `./devdata/work-items-in/split-orders-file-test-input/work-items.json`
- For task `Load and Process All Orders`:
  - `./devdata/work-items-in/process-orders-test-from-outputs/work-items.json`

The `RPA.Robocorp.WorkItems` library can be controlled with specific environment variables to control the input and output sources. In this example under `./devdata` you can find three different JSON files that demonstrate the selection:
- [`env.json`](./devdata/env.json): This is used as default by Robocorp Lab and RCC command-line and points to the input for task `Split orders file`
- [`env-process-orders.json`](./devdata/env-process-orders.json): Points to the input for task `Load and Process All Orders`
- [`env-split-orders.json`](./devdata/env-split-orders.json): Points to the input for task `Split orders file`

By default the `env.json` is used by Robocorp Lab so the inputs and output paths defined there decide which input is used. You can edit that file change what you are testing.

To run specific tasks with specific inputs in the command-line or Robocorp Lab Terminal you can run the following commands:
- Run `Split orders file` with test input:
  - `rcc task run -t "Split orders file" -e ./devdata/env-split-orders.json`
- Run `Load and Process All Orders` with test input:
  - `rcc task run -t "Load and Process All Orders" -e ./devdata/env-process-orders.json`

## Control room setup

To see how to set up Control Room and understand more about how work items are used, see the following article: [Using work items](https://robocorp.com/docs/development-guide/control-room/data-pipeline).
