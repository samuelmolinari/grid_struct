require 'spec_helper'

describe ::GridStruct::Selector do

  let(:grid) { GridStruct.new(9,9) }
  let(:indexes) { [0,3,34,57] }
  subject(:selector) { described_class.new(grid,*indexes)  }

  before(:each) do
    grid.map! do |value,row,column|
      ((row * grid.columns) + column) * 2
    end
  end

  it { is_expected.to have_attributes(grid: grid,
                                      indexes: indexes) }

  describe '#[]' do
    it 'retrieve the x element in the current selection' do
      expect(selector[0]).to eq 0
      expect(selector[1]).to eq 6
      expect(selector[2]).to eq 68
      expect(selector[3]).to eq 114
    end

    context 'when mapped index is nil' do
      let(:broken_selector) { described_class.new(grid, [0,nil,nil,nil]) }

      it 'returns nil' do
        expect(broken_selector[1]).to be_nil
      end
    end
  end

  describe '#[]=' do
    it 'sets the value in the grid through the selector' do
      selector[0] = -10
      selector[1] = -3
      selector[2] = 'hello world'
      expect(grid.store[0]).to eq -10
      expect(grid.store[3]).to eq -3
      expect(grid.store[34]).to eq 'hello world'
    end

    context 'when mapped index is nil' do
      let(:broken_selector) { described_class.new(grid, [0,nil,nil,nil]) }

      it 'ignores action' do
        store = grid.store
        broken_selector[1] = 100
        expect(grid.store).to eq store
      end
    end
  end

  describe '#dimensions' do
    it 'sets the virtual dimensions of the current selection' do
      selector.dimensions(2,3)
      expect(selector.rows).to eq 2
      expect(selector.columns).to eq 3
    end
  end

  describe '#to_a' do
    it 'fetches and returns selector values into an array' do
      expect(selector.to_a).to eq [0,6,68,114]
    end
    it 'does not modify the grid when manipulating retuning array' do
      array = selector.to_a
      array[0] = -100
      expect(grid.store[0]).not_to eq -100
    end
  end

  describe 'to_grid' do
    it 'converts current selection into a new grid, with the given dimensions' do
      expect(selector.to_grid(2,2)).to eq GridStruct.new(2,2,[0,6,68,114])
    end
  end

end
