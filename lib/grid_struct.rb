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

  def map_row!(n, &block)
    return map_line!(n, @columns, true, &block)
  end

  def map_column!(n, &block)
    return map_line!(n, @rows, false, &block)
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
        yield(slice(index, rows: rows, columns: columns), index)

      end
    end
  end

  def get(row,column)
    @store[get_index(row,column)]
  end

  ##
  # TODO Improve
  def slice(index,dimensions)
    rows = dimensions[:rows]
    columns = dimensions[:columns]
    sub_columns = (@columns / columns.to_f).ceil

    sub_row = index / sub_columns
    sub_column = index - (sub_row * sub_columns)

    indexes = retrieve_sliced_indexes(rows,columns,sub_row,sub_column)

    return GridStruct::Selector.new(self, *indexes).dimensions(rows,columns)
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

  def within_bounds?(row,column)
    row_within_bounds?(row) && column_within_bounds?(column)
  end

  protected

  def fit_selection_within_same_row(start_index, end_index)
    start_row = get_row_column_at(start_index)[:row]
    end_row = get_row_column_at(end_index)[:row]

    if start_row != end_row
      extras = [0,(end_index - @columns)].max % @columns
      end_index -= extras
    end

    return start_index...end_index
  end

  def retrieve_sliced_indexes(rows, columns, sub_row, sub_column)
    rows.times.inject([]) do |memo, r|
      start_index = (r * @columns) +
        (sub_row * rows * @columns) +
        (sub_column * columns)
      end_index = start_index + columns

      final_row_indexes = fit_selection_within_same_row(start_index, end_index).to_a
      final_row_indexes.fill(nil,final_row_indexes.size...columns)

      memo += final_row_indexes
    end
  end

  def line_within_bounds?(n, axis_size)
    n >= 0 && n < axis_size
  end

  def row_within_bounds?(row)
    line_within_bounds?(row, @rows)
  end

  def column_within_bounds?(column)
    line_within_bounds?(column, @columns)
  end

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

    if !diagonal_indexes.include?(index) && within_bounds?(row, column)
      diagonal_indexes.method(action).call(get_index(row,column))

      fetch_diagonal_index(row, column, row_direction, column_direction, diagonal_indexes, -1)
      fetch_diagonal_index(row, column, row_direction, column_direction, diagonal_indexes, 1)
    end

    return diagonal_indexes
  end

  def fetch_diagonal_index(row, column, row_direction, column_direction, diagonal_indexes, sign)
    row = row + sign * row_direction
    column = column + sign * column_direction
    action = sign > 0 ? :push : :unshift

    diagonal_builder({ row: row,
                       column: column },
                     row_direction,
                     column_direction,
                     diagonal_indexes,
                     action)
  end

  def map_line!(n, other_axis_size, is_row)
    other_axis_size.times.each do |other_axis|
      index = is_row ? get_index(n,other_axis) : get_index(other_axis,n)
      value = @store[index]
      @store[index] = yield(value,other_axis)
    end
    return self
  end

end
