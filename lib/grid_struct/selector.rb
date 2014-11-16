class ::GridStruct::Selector

  attr_reader :grid, :indexes

  def initialize(grid,*indexes)
    @grid = grid
    @indexes = indexes.uniq.freeze
  end

  def [](i)
    @grid.store[@indexes[i]]
  end

  def []=(i,value)
    @grid.store[@indexes[i]] = value
  end

  def to_a
    @indexes.map do |index|
      @grid.store[index]
    end
  end

  def to_grid(rows,columns)
    GridStruct.new(rows,columns,to_a)
  end

end
