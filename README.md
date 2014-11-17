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

```
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

### Selectors

Selector gives you access to line of values within the grid, and allows you to
only act on that line. Each selector return a (or an array of) GridStruct::Selector.

#### Overview

A selector has the following instances:

- ``grid``: The grid it is selecting from
- ``indexes``: An array of indexes mapping to the selected values in the grid store

```ruby
grid = GridStruct.new(3,3)

grid.map! do |value, row, column|
  (row * grid.columns + column) * 10
end

grid.row(0) # => #<GridStruct::Selector:0x007fb3d11decf0 @grid=#<GridStruct:0x007fb3d15541f0 @columns=3, @rows=3, @store=[0, 10, 20, 30, 40, 50, 60, 70, 80]>, @indexes=[0, 1, 2]>
```

You can retrieve and update values using ``[]``. It will map the action to the grid.

```ruby
first_row = grid.row(0)

first_row.to_a # => [0,10,20]

first_row[0] # => 0
first_row[1] # => 10
first_row[2] # => 20

first_row[0] = -100

grid.to_a # => [-100,10,20,30,40,50,60,70,80]

```

#### Row

To select a specific row, use the method ``row``

```
GridStruct#row(row_number)
```

```ruby
rows = []

# Fetch selector for every rows
grid.rows.times.each do |row_index|
  rows[row_index] = grid.row(row_index)
end
```

#### Column

To select a specific column, use the method ``column``

```
GridStruct#column(column_number)
```

```ruby
columns = []

# Fetch selector for every columns
grid.columns.times.each do |column_index|
  columns[column_index] = grid.column(column_index)
end
```

#### Diagonals

The diagonals retrieval works slightly differently from the two previous methods.
In order to retrieve diagonals, you must provide the coordinates of a cell in the grid. This will retrieve the diagonals that cross through that specific cell.
The returned array can be of size 0 (no diagonals found, for example, in a grid of size 1), 1 (when retrieving diagonals from the corners of the grid) or 2.

```
GridStruct#diagonals(1,1) # => [#<GridStruct::Selector ...>, #<GridStruct::Selector ...>]
```

```ruby
diagonals = grid.diagonals(1,1)

diagonals.first.to_a # => [0,40,80]
diagonals.last.to_a # => [30,40,60]

corner_diagonal = grid.diagonals(0,0) # fetch diagonals from top left corner

corner_diagonal.size # => 1
corner_diagonal.first.to_a # => [0,40,80]
```

#### Slice

Imagine a slice as a projection of a section of your grid.
Use the ``slice`` method to access a single slice.

```
GridStruct#slice(slice_index, rows: slice_rows, columns: slice_columns) # => #<GridStruct::Selector ...>
```

In the following example, we are manipulating a sudoku grid, and we want to access the middle 3x3 square

```ruby
sudoku_grid = GridStruct.new(9,9)

sudoku_grid.map! do |v, r, c|
  (r * sudoku_grid.columns) + c + 1
end

sudoku_grid.slice(4, rows: 3, columns: 3) # => #<GridStruct:0x007fb3d16e4e70 @columns=3, @rows=3, @store=[31, 32, 33, 40, 41, 42, 49, 50, 51]>
```

Use the ``each_slice`` method to go through each slices

```
GridStruct#each_slice(slice_rows,slice_columns) { |slice, slice_index| # Do something }
```

```ruby
sudoku_grid.each_slice(3,3) do |slice, index|
  # Do something
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
