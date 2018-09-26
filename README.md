# Coding Challenge - Order Bundle Processor
Given an order, determine the cost and bundle breakdown for each item.

## Install dependencies:
    `bundle install`

## Usage
    # Create new order
    order = Order.new('10 IMG 15 FLAC 13 VID')

    # Process and get hashmap of bundle breakdown
    bundles = order.process

    # Process and print bundle breakdown
    order.process_and_print

## Sample Output:
```
10 IMG
    1 x $800
ITEM TOTAL= 800
15 FLAC
    2 x $1620
    1 x $427.5
ITEM TOTAL= 3667.5
13 VID
    2 x $1800
    1 x $570
ITEM TOTAL= 4170
```

## Run unit tests
    `rake test`