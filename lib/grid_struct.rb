require 'grid_struct/version'
require 'grid_struct/selector'

class GridStruct

  attr_reader :store,
              :rows,
              :columns

  def initialize(rows, columns, store = [])
    @rows = rows
    @columns = columns
    @store = store || []
  end

  def set(row,column)
    @store[get_index(row,column)] = yield
  end

  def map!
    size.times.map do |index|
      value = @store[index]
      row_column = get_row_column_at(index)
      @store[index] = yield(value, row_column[:row], row_column[:column])
    end
    return self
  end

  def map_row!(n)
    @columns.times.each do |column|
      index = get_index(n,column)
      value = @store[index]
      @store[index] = yield(value,column)
    end
    return self
  end

  def map_column!(n)
    @rows.times.each do |row|
      index = get_index(row,n)
      value = @store[index]
      @store[index] = yield(value,row)
    end
    return self
  end

  def each
    @store.fill(nil,@store.size...size).each.with_index do |value, index|
      row_column = get_row_column_at(index)
      yield(value,row_column[:row],row_column[:column])
    end
  end

  def each_slice(rows,columns)
    sub_rows = (@rows / rows.to_f).ceil
    sub_columns = (@columns / columns.to_f).ceil

    sub_rows.times.each do |sub_row|
      sub_columns.ceil.times.each do |sub_column|

        index = sub_column + (sub_row * sub_columns)
        yield(slice_at(index, rows: rows, columns: columns), index)

      end
    end
  end

  def get(row,column)
    @store[get_index(row,column)]
  end

  ##
  # TODO Improve
  def slice_at(index,dimensions)
    grid = GridStruct.new(dimensions[:rows], dimensions[:columns])
    rows = dimensions[:rows]
    columns = dimensions[:columns]
    sub_columns = (@columns / columns.to_f).ceil

    sub_row = index / sub_columns
    sub_column = index - (sub_row * sub_columns)

    store = []
    indexes = []
    rows.times.each do |r|
      start_index = (r * @columns) +
                    (sub_row * rows * @columns) +
                    (sub_column * columns)
      end_index = start_index + columns

      start_row = get_row_column_at(start_index)[:row]
      end_row = get_row_column_at(end_index)[:row]

      if start_row != end_row
        extras = [0,(end_index - @columns)].max % @columns
        end_index -= extras
      end

      indexes += (start_index...end_index).to_a
      final_row = @store[start_index...end_index] || []
      final_row.fill(nil,final_row.size...columns)
      store += final_row
    end
    grid.instance_variable_set(:@store, store)

    return grid
  end

  def row(n)
    start_index = (n * @columns)
    end_index = start_index + @columns
    GridStruct::Selector.new(self,*(start_index...end_index))
  end

  def column(n)
    GridStruct::Selector.new(self,*@rows.times.map do |row|
      get_index(row,n)
    end)
  end

  def diagonals(row,column)
    selectors = []

    first = diagonal_builder({row: row, column: column})
    second = diagonal_builder({row: row, column: column}, 1, -1)

    selectors.push(GridStruct::Selector.new(self, *first)) if first.size > 1
    selectors.push(GridStruct::Selector.new(self, *second)) if second.size > 1

    return selectors
  end

  def size
    @rows * @columns
  end

  def to_a
    store_size = @store.size
    return @store.dup.fill(nil,store_size...size)
  end

  def ==(other)
    @store == other.instance_variable_get(:@store)
  end

  protected

  def get_index(row,column)
    (row * @columns) + column
  end

  def get_row_column_at(index)
    row = index / @columns
    column = index - (row * @columns)
    return { row: row, column: column }
  end

  def diagonal_builder(coordinates, row_direction = 1, column_direction = 1, diagonal_indexes = [], action = :push)
    row = coordinates[:row]
    column = coordinates[:column]
    index = get_index(row,column)

    if !diagonal_indexes.include?(index) &&
        row >= 0 &&
        column >= 0 &&
        row < @rows &&
        column < @columns

      diagonal_indexes.method(action).call(get_index(row,column))

      diagonal_builder({ row: row - (row_direction * 1),
                         column: column - (column_direction * 1) },
                         row_direction,
                         column_direction,
                         diagonal_indexes,
                         :unshift)

      diagonal_builder({ row: row + (row_direction * 1),
                         column: column + (column_direction * 1) },
                         row_direction,
                         column_direction,
                         diagonal_indexes,
                         :push)

    end

    return diagonal_indexes
  end

end
