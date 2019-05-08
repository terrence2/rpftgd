#!/bin/env ruby

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: befunge.rb [options] <program.bf>"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on("-s", "--summary", "Show summary after completion") do |v|
    options[:summary] = v
  end
end.parse!

fp = File::open(ARGV.first)
fp.close

class Machine
  attr_accessor :instruction_count

  def initialize(program)
  end

  def eval
    42
  end
end

machine = Machine.new("@")
result = machine.eval

if options[:summary]
  puts "ret:#{result}"
  puts "cnt:#{machine.instruction_count}"
end
