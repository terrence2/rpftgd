module Test
  def self.short_operation
    number1 + number2
  end

  def self.number1
    24
  end

  def self.number2
    48
  end
end

COUNT = 10000000
start_time = Time.now
(1..COUNT).each { |_| Test.short_operation() }
elapsed_time = Time.now - start_time
puts "short_operation() takes: #{elapsed_time / COUNT * 1000000} us per iteration"
