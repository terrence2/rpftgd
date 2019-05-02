#!/bin/env ruby
require 'timeout'

tests = Dir["spec/**/*.bf"]

tests.sort.each do |test|
  fp = File::open(test)
  lines = fp.readlines
  fp.close

  assertions = {}
  lines.each do |line|
    if line.start_with?('#')
      parts = line[1..-1].split(':')
      assertions[parts.first.to_sym] = parts.last.to_i
    end
  end

  print "#{test}: "
  STDOUT.flush

  output = ""
  begin
    status = Timeout::timeout(1) do
      output = `ruby befunge.rb -s #{test}`
    end
  rescue Timeout::Error
    procs = `pgrep ruby`
    procs.lines do |line|
      if line.to_i != Process.pid
        `kill #{line}`
      end
    end
  end

  results = {}
  output.lines do |line|
    parts = line.split(':')
    results[parts.first.to_sym] = parts.last.to_i
  end

  passed = true
  assertions.each do |(kind, expect)|
    if results[kind] != expect
      passed = false
    end
  end

  if passed
    puts "\033[32mok\033[0m"
  elsif output == ""
    puts "\033[33mtimeout\033[0m"
    puts "  expected: #{assertions}"
    puts "  results:  :timeout"
  else
    puts "\033[31mfail\033[0m"
    puts "  expected: #{assertions}"
    puts "  results:  #{results}"
  end
end