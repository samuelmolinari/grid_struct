class ::GridStruct::Selector

  attr_reader :grid, :indexes, :rows, :columns

  def initialize(grid,*indexes)
    @grid = grid
    @indexes = indexes.freeze
  end

  def dimensions(rows,columns)
    @rows = rows
    @columns = columns
    return self
  end

  def [](i)
    mapped_index = @indexes[i]
    mapped_index.nil? ? nil : @grid.store[mapped_index]
  end

  def []=(i,value)
    mapped_index = @indexes[i]
    @grid.store[mapped_index] = value unless mapped_index.nil?
  end

  def to_a
    @indexes.size.times.map do |i|
      self[i]
    end
  end

  def to_grid(rows = nil,columns = nil)
    rows ||= @rows
    columns ||= @columns
    GridStruct.new(rows,columns,to_a)
  end

end
