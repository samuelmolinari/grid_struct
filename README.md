# GridStruct

Manipulate grid like structure in Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'grid_struct'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grid_struct

## Usage

### Create a GridStruct

In order to create a grid, you have to pass a 2 arguments:

- ``rows``: the number of rows your grid has (the height of the grid)
- ``columns``: the number columns your grid has (the width of the grid)

```ruby
rows = 9
columns = 5

# Create a grid of size 5x9
grid = GridStruct.new(rows, columns)

grid.size # => 45
grid.columns # => 5
grid.rows # => 9
```

It is possible to initialize the array with pre-set values.
The 3rd argument must be an array.

If we want to initialize the following grid:

```
+---+---+---+
| X | O | O |
+---+---+---+
| X | x | O |
+---+---+---+
| O | X | O |
+---+---+---+

```

Use the following array structure:

```ruby
#           +-----------+-----------+-----------+
#           |   ROW 0   |   ROW 1   |   ROW 2   |
# +---------+-----------+-----------+-----------+
# | COLUMNS | 0 | 1 | 2 | 0 | 1 | 2 | 0 | 1 | 2 |
grid_data = ['X','O','O','X','X','O','O','X','O']

tic_tac_toe = GridStruct.new(3, 3, grid_data)
```

``GridStruct`` actually store your values extactly the same way, in a 1-dimentional array.

### Basics

Now you know how to create grids, it's time to learn how to use our new data structure.

#### Read the data store

As mentionned above, your data are stored in a 1-dimentional array.

```ruby
tic_tac_toe.store # => ["X","O","O","X","X","O","O","X","O"]

GridStruct.new(9,9).store # => []
```

As you can see, the ``store`` always starts as an empty array unless you decide to pre-fill the grid.

#### Set value

To set a value, pass the row and column you want to fill, and a block that will return the value

```
GridStruct#set(row, column) { value }
```

```ruby
sudoku_grid = GridStruct.new(9,9)

sudoku_grid.set(0,0) { 'Hello World' }
sudoku_grid.store # => ["Hello World"]

sudoku_grid.set(1,0) { 'Row: 1, Col: 0' }
sudoku_grid.store # => ["Hello World",nil,nil,nil,nil,nil,nil,nil,"Row: 1, Col: 0"]
```

#### Get value

To get a value at a specific coordinate, use th ``get`` method.

```
GridStruct#get(row, column) # => value
```

```ruby
sudoku_grid.get(1,0) # => "Row: 1, Col: 0"
```

### Iterate

You can iterate through the grid using the each method

```ruby
GridStruct#each { |value, row, column| # Do something }
```

### Mass update

#### Grid

Incase you need to update each element within the grid, use the ``map!`` method

```
GridStruct#map! { |value, row, column| # Return new value  }
```

```ruby
grid = GridStruct.new(3,3)
grid.map! { |value, row, column| (row * grid.columns) + column }

grid.store # => [0,1,2,3,4,5,6,7,8]
```

#### Row

You can update a specific row if needed, for example, if we want to update the middle row

```
GridStruct#map_row! { |value, column| # Return new value  }
```

```
                      +---+---+---+
                      | 0 | 1 | 2 |
                      +---+---+---+
 Update this row  →   | 3 | 4 | 5 |
                      +---+---+---+
                      | 6 | 7 | 8 |
                      +---+---+---+
```

```ruby
grid.map_row!(1) { |value| value * 10 }

grid.store # => [0,1,2,30,40,50,6,7,8]
```


#### Column

You can update a specific row if needed, for example, if we want to update the middle row

```
GridStruct#map_column! { |value, row| # Return new value  }
```

```
     Update this columns
              ↓
    +---+---+---+
    | 0 | 1 | 2 |
    +---+---+---+
    | 3 | 4 | 5 |
    +---+---+---+
    | 6 | 7 | 8 |
    +---+---+---+
```

```ruby
grid.map_column!(2) { |value| value * 10 }

grid.store # => [0,1,20,3,4,50,6,7,80]
```

### Selection

TODO

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
