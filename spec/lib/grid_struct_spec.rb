require 'spec_helper'

describe ::GridStruct do

  let(:sudoku_grid) { GridStruct.new(9,9) }
  before(:each) do
    #  Fill grid as such
    #
    #  |----|----|----|----|----|----|----|----|----|
    #  |  0 |  1 |  2 |  3 |  4 |  5 |  6 |  7 |  8 |
    #  |----|----|----|----|----|----|----|----|----|
    #  |  9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 |
    #  |----|----|----|----|----|----|----|----|----|
    #  | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 |
    #  |----|----|----|----|----|----|----|----|----|
    #  | 27 | 28 | 29 | 30 | 31 | 32 | 33 | 34 | 35 |
    #  |----|----|----|----|----|----|----|----|----|
    #  | 36 | 37 | 38 | 39 | 40 | 41 | 42 | 43 | 44 |
    #  |----|----|----|----|----|----|----|----|----|
    #  | 45 | 46 | 47 | 48 | 49 | 50 | 51 | 52 | 53 |
    #  |----|----|----|----|----|----|----|----|----|
    #  | 54 | 55 | 56 | 57 | 58 | 59 | 60 | 61 | 62 |
    #  |----|----|----|----|----|----|----|----|----|
    #  | 63 | 64 | 65 | 66 | 67 | 68 | 69 | 70 | 71 |
    #  |----|----|----|----|----|----|----|----|----|
    #  | 72 | 73 | 74 | 75 | 76 | 77 | 78 | 79 | 80 |
    #  |----|----|----|----|----|----|----|----|----|

    sudoku_grid.map! do |value, row, column|
      row * sudoku_grid.columns + column
    end
  end

  let(:rows) { 2 }
  let(:columns) { 3 }
  subject(:grid) { GridStruct.new(rows, columns) }

  it { is_expected.to have_attributes(rows: rows,
                                      columns: columns) }

  describe '#size' do
    it 'is the multiplication of with and height' do
      expect(grid.size).to be rows * columns
    end
  end

  describe '#set' do
    it 'sets the value at the given row and column' do
      grid.set(0,0) { 1 }
      store = grid.instance_variable_get(:@store)
      expect(store).to eq [1]

      grid.set(1,0) { 2 }
      store = grid.instance_variable_get(:@store)
      expect(store).to eq [1,nil,nil,2]
    end
  end

  describe '#each' do
    before(:each) do
      grid.instance_variable_set(:@store, [0,1,2,3,4,5])
    end

    it 'iterates through each elements of the grid (left to right, top to bottom)' do
      values = []
      grid.each do |element,row,column|
        values[(row * grid.columns) + column] = element
      end
      expect(values.size).to be grid.size
      expect(values).to eq grid.to_a
    end
  end

  describe '#map!' do
    it 'replaces all the elements in the grid' do
      grid.map! do |value, row, column|
        (row + 1) * (column + 1)
      end
      store = grid.instance_variable_get(:@store)
      expect(store).to eq [1,2,3,2,4,6]
    end
  end

  describe '#map_row!' do
    it 'replaces the elements in the targeted row' do
      grid.map_row!(0) { |value, column| column }
      store = grid.instance_variable_get(:@store)
      expect(store).to eq [0,1,2]

      grid.map_row!(1) { |value, column| column**2 }
      store = grid.instance_variable_get(:@store)
      expect(store).to eq [0,1,2,0,1,4]
    end
  end

  describe '#map_column!' do
    it 'replaces the elements in the targeted column' do
      grid.map_column!(0) { |value, row| row }
      store = grid.instance_variable_get(:@store)
      expect(store).to eq [0,nil,nil,1]

      grid.map_column!(1) { |value, row| row + 1 }
      store = grid.instance_variable_get(:@store)
      expect(store).to eq [0,1,nil,1,2]
    end
  end

  describe '#each_slice' do
    it 'iterates through sub-grids of the given rows and columns' do
      sub_grids = []
      sudoku_grid.each_slice(3,3) do |sub_grid,index|
        sub_grids[index] = sub_grid
      end
      expect(sub_grids[0].to_a).to eq [0,1,2,9,10,11,18,19,20]
      expect(sub_grids[1].to_a).to eq [3,4,5,12,13,14,21,22,23]
      expect(sub_grids[2].to_a).to eq [6,7,8,15,16,17,24,25,26]
      expect(sub_grids[3].to_a).to eq [27,28,29,36,37,38,45,46,47]
      expect(sub_grids[4].to_a).to eq [30,31,32,39,40,41,48,49,50]
      expect(sub_grids[5].to_a).to eq [33,34,35,42,43,44,51,52,53]
      expect(sub_grids[6].to_a).to eq [54,55,56,63,64,65,72,73,74]
      expect(sub_grids[7].to_a).to eq [57,58,59,66,67,68,75,76,77]
      expect(sub_grids[8].to_a).to eq [60,61,62,69,70,71,78,79,80]
    end

    context 'when slice is equal to the grid' do
      it 'iterates a single time with a copy of the current grid' do
        selector = nil
        sudoku_grid.each_slice(9,9) do |sub_grid|
          selector = sub_grid
        end
        expect(selector.to_grid).to eq sudoku_grid
      end
    end

    context 'when slice is bigger than the grid' do
      it 'iterates a single time with content of current grid with extra edges' do
        selector = nil
        sudoku_grid.each_slice(10,10) do |sub_grid|
          selector = sub_grid
        end
        sudoku_grid.rows.times.each do |row_index|
          expect(selector.to_grid.row(row_index).to_a).to eq (sudoku_grid.row(row_index).to_a + [nil])
        end
        sudoku_grid.columns.times.each do |column_index|
          expect(selector.to_grid.column(column_index).to_a).to eq (sudoku_grid.column(column_index).to_a + [nil])
        end
      end
    end

    context 'when last slice bleeds out of the grid' do
      it 'nullify the extras' do
        sub_grids = []
        sudoku_grid.each_slice(2,4) do |sub_grid,index|
          sub_grids[index] = sub_grid
        end
        expect(sub_grids[2].to_a).to eq [8,nil,nil,nil,17,nil,nil,nil]
        expect(sub_grids[5].to_a).to eq [26,nil,nil,nil,35,nil,nil,nil]
        expect(sub_grids[8].to_a).to eq [44,nil,nil,nil,53,nil,nil,nil]
        expect(sub_grids[11].to_a).to eq [62,nil,nil,nil,71,nil,nil,nil]
        expect(sub_grids[12].to_a).to eq [72,73,74,75,nil,nil,nil,nil]
        expect(sub_grids[13].to_a).to eq [76,77,78,79,nil,nil,nil,nil]
        expect(sub_grids[14].to_a).to eq [80,nil,nil,nil,nil,nil,nil,nil]
      end
    end
  end

  describe '#get' do
    context 'a non-set cell' do
      it 'returns nil' do
        expect(grid.get(0,0)).to be_nil
      end
    end
    context 'an already set cell' do
      before(:each) do
        grid.instance_variable_set(:@store, [nil,8,nil,9,2,nil])
      end

      it 'returns the stored value at the given row and column' do
        expect(grid.get(0,0)).to be_nil
        expect(grid.get(0,1)).to be 8
        expect(grid.get(0,2)).to be_nil
        expect(grid.get(1,0)).to be 9
        expect(grid.get(1,1)).to be 2
        expect(grid.get(1,2)).to be_nil
      end
    end
  end

  describe '#row' do
    before(:each) do
      grid.instance_variable_set(:@store, [nil,8,nil,9,2,nil])
    end

    it 'returns a selector' do
      expect(grid.row(0)).to be_kind_of(GridStruct::Selector)
    end

    it 'retrieves a selector of the requested row' do
      expect(grid.row(0).to_a).to eq [nil,8,nil]
      expect(grid.row(1).to_a).to eq [9,2,nil]
    end
  end

  describe '#column' do
    before(:each) do
      grid.instance_variable_set(:@store, [nil,8,nil,9,2,nil])
    end

    it 'returns a selector' do
      expect(grid.column(0)).to be_kind_of(GridStruct::Selector)
    end

    it 'retrieves a selector of the requested column' do
      expect(grid.column(0).to_a).to eq [nil,9]
      expect(grid.column(1).to_a).to eq [8,2]
      expect(grid.column(2).to_a).to eq [nil,nil]
    end
  end

  describe '#diagonals' do
    it 'returns an array' do
      expect(grid.diagonals(0,0)).to be_kind_of Array
    end

    context 'when fetching diagonals not from a corner' do
      it 'returns 2 selectors' do
        diagonals = sudoku_grid.diagonals(4,4)
        expect(diagonals.size).to be 2
        expect(diagonals.first).to be_kind_of(GridStruct::Selector)
        expect(diagonals.last).to be_kind_of(GridStruct::Selector)
      end

      it 'returns the diagonals crossing the given coordinates' do
        diagonals = sudoku_grid.diagonals(4,4)
        expect(diagonals.first.to_a).to eq [0,10,20,30,40,50,60,70,80]
        expect(diagonals.last.to_a).to eq [8,16,24,32,40,48,56,64,72]
      end

      context 'the returned selectors' do
        it 'approprietly modify its matching element' do
          diagonals = sudoku_grid.diagonals(4,4)
          diagonals.first[4] = -100
          expect(sudoku_grid.get(4,4))
        end
      end
    end

    context 'when fetching diagonals from a corner' do
      it 'only returns 1 diagonal selector' do
        expect(sudoku_grid.diagonals(0,0).size).to be 1
        expect(sudoku_grid.diagonals(0,sudoku_grid.columns - 1).size).to be 1
        expect(sudoku_grid.diagonals(sudoku_grid.rows - 1,0).size).to be 1
        expect(sudoku_grid.diagonals(sudoku_grid.rows - 1, sudoku_grid.columns - 1).size).to be 1
      end
    end
  end

  describe '#slice' do
    it 'returns a selector' do
      expect(sudoku_grid.slice(0, rows: 3, columns: 3)).to be_kind_of(GridStruct::Selector)
    end

    context 'the returned selector' do
      it 'modifies its matching element' do
        slice = sudoku_grid.slice(0, rows: 3, columns: 3)
        slice[4] = -100
        expect(sudoku_grid.get(1,1)).to eq -100
      end

      context 'when slice goes out of bound' do
        it 'adds extras when converting to grid' do
          slice = sudoku_grid.slice(2, rows: 2, columns: 4)
          expect(slice.to_grid.to_a).to eq [8,nil,nil,nil,17,nil,nil,nil]
        end
      end
    end
  end

  describe '#to_a' do
    it 'returns an array matching size of the grid' do
      expect(grid.to_a.size).to be grid.size
    end

    it 'returns content of grid store' do
      grid.instance_variable_set(:@store, [0,1,2,3,4,5])
      expect(grid.to_a).to eq [0,1,2,3,4,5]
    end

    it 'returns a copy' do
      grid.instance_variable_set(:@store, [0,1,2,3,4,5])
      array = grid.to_a
      array[0] = 100
      expect(grid.get(0,0)).to be 0
    end
  end
end
