require "rainfall"

describe "Rainfall" do
  it "can compute volume" do
    expect(Rainfall.compute_volume([3, 0, 0, 2, 4])).to eq(7)
  end

  it "goes FAST" do
    SIZE = 1500
    ITERATIONS = 1000
    input = Array.new(SIZE) { rand(1..9) }
    start_time = Time.now
    Rainfall.compute_volume(input, ITERATIONS)
    elapsed_time = Time.now - start_time
    puts "short_operation() takes: #{elapsed_time / ITERATIONS * 1000000} us per iteration" 

  end
end