require 'minitest/autorun'

class Rainfall
  attr_reader :heights

  def initialize(heights)
    @heights = heights
  end

  def calculate_volume
    max_per_col =
      heights.map.with_index do |height, i|
        next 0 if i == 0
        next 0 if i == heights.length - 1
        left_of = heights[0..i]
        right_of = heights[i..-1]
        max_height_of_water = [left_of.max, right_of.max].min
        [max_height_of_water - height, 0].max
      end
    max_per_col.sum
  end
end

describe Rainfall do
  it 'must bark when spoken to' do
    Rainfall.new([3, 0, 0, 2, 4]).calculate_volume.must_equal 7
  end

  it 'really long solution' do
    Array.new(10000000) { rand(1..9) }
  end
end
