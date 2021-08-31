# Web store order processor: multiple work items example

This robot splits orders by customer from an incoming Excel file. The orders are then handled individually and in parallel.

The robot demonstrates the Work Items feature of Robocorp Control Room:

- Triggering a process with custom payloads (input)
- Passing data and files between process steps
- Parallel execution of steps

## Tasks

The robot is split into two tasks, meant to be run as separate steps. The first task generates (produces) data, and the second one reads (consumes) and processes that data.

> [Producer-consumer](https://en.wikipedia.org/wiki/Producer%E2%80%93consumer_problem), Wikipedia.

### The first task (the producer)

- Reads an Excel file from the work item
- Splits it into orders by customer
- Creates a new work item for each order

### The second task (the consumer)

- Reads the products in the order from the work item
- Logs in to the web store
- Orders the products

## Excel input file

The first task expects an [Excel file](devdata/orders.xlsx) in a specific format:

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

## Local development

When running in **Control Room**, the work items will be automatically managed and passed between steps in the process. However, when running locally, the work items can be simulated using a JSON-based file.

The `RPA.Robocorp.WorkItems` library can be controlled with specific environment variables, as seen in the [`env.json`](./devdata/env.json) file.

This example also includes two example inputs for both tasks in the process, called [`items1.json`](./devdata/items1.json) and [`items2.json`](./devdata/items2.json). Depending on which task is being developed, different work item files can be used for development purposes.

In local development, a JSON file is generated for the output. This is the contents of the `items1.output.json` output file after running the first task that groups the products by customer:

```json
[
  {
    "payload": {
      "products": [
        {
          "Name": "Camden Martin",
          "Item": "Sauce Labs Bolt T-Shirt",
          "Zip": 1196
        }
      ]
    },
    "files": {}
  },
  {
    "payload": {
      "products": [
        {
          "Name": "Gregg Arroyo",
          "Item": "Sauce Labs Onesie",
          "Zip": 4418
        },
        {
          "Name": "Gregg Arroyo",
          "Item": "Sauce Labs Bolt T-Shirt",
          "Zip": 4418
        }
      ]
    },
    "files": {}
  },
  {
    "payload": {
      "products": [
        {
          "Name": "Sol Heaton",
          "Item": "Sauce Labs Bolt T-Shirt",
          "Zip": 3695
        },
        {
          "Name": "Sol Heaton",
          "Item": "Sauce Labs Fleece Jacket",
          "Zip": 3695
        },
        {
          "Name": "Sol Heaton",
          "Item": "Sauce Labs Onesee",
          "Zip": 3695
        }
      ]
    },
    "files": {}
  },
  {
    "payload": {
      "products": [
        {
          "Name": "Zoya Roche",
          "Item": "Sauce Labs Bolt T-Shirt",
          "Zip": 3013
        },
        {
          "Name": "Zoya Roche",
          "Item": "Sauce Labs Fleece Jacket",
          "Zip": 3013
        },
        {
          "Name": "Zoya Roche",
          "Item": "Sauce Labs Onesie",
          "Zip": 3013
        }
      ]
    },
    "files": {}
  }
]
```

Each `payload` section in the generated output JSON file corresponds to one work item.

## Control room setup

To see how to set up Control Room and understand more about how work items are used, see the following article: [Using work items](https://robocorp.com/docs/development-guide/control-room/data-pipeline).
