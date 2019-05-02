def sqrt(x)
  sqrt_iter(1.0, x)
end

def sqrt_iter(guess, x)
  return guess if good_enough?(guess, x)
  sqrt_iter(improve(guess, x), x)
end

def improve(guess, x)
  average(guess, x / guess)
end

def average(x, y)
  (x + y) / 2
end

def good_enough?(guess, x)
  (guess * guess - x).abs < 0.001
end

puts "sqrt:      #{sqrt 99999999999}"
puts "Math.sqrt: #{Math.sqrt 99999999999}"
