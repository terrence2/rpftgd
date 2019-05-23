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

SIZE = 1500
ITERATIONS = 1000
input = Array.new(SIZE) { rand(1..9) }
rf = Rainfall.new(input)
start_time = Time.now
(1..ITERATIONS).each do |_|
  rf.calculate_volume
end
elapsed_time = Time.now - start_time
puts "short_operation() takes: #{elapsed_time / ITERATIONS * 1000000} us per iteration"

