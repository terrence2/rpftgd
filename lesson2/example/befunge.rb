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
lines = fp.readlines.map { |line| line[0...-1] }
fp.close

max_line_length = lines.map(&:length).max
program = lines.map { |line| line.ljust(max_line_length) }

class ProgramCounter
  def initialize(limit_x:, limit_y:)
    @limit_x = limit_x
    @limit_y = limit_y
    @x = 0
    @y = 0
    @dx = 1
    @dy = 0
  end

  def go_east
    @dx = 1
    @dy = 0
  end

  def go_west
    @dx = -1
    @dy = 0
  end

  def go_north
    @dx = 0
    @dy = -1
  end

  def go_south
    @dx = 0
    @dy = 1
  end

  def move
    @x += @dx
    @y += @dy
    @x %= @limit_x
    @y %= @limit_y
    while @x < 0
      @x += @limit_x
    end
    while @y < 0
      @y += @limit_y
    end
  end

  def x
    @x
  end

  def y
    @y
  end
end

class Machine
  attr_accessor :instruction_count

  def initialize(program)
    @program = program
    @stack = []
    @pc = ProgramCounter.new(limit_x: @program[0].length, limit_y: @program.length)

    @instruction_count = 0
  end

  def eval
    while true
      @instruction_count += 1
      instr = @program[@pc.y][@pc.x]
      if !dispatch(instr)
        break
      end
      @pc.move
    end
    @stack.last
  end

  def dispatch(instr)
    case instr
    when '@'
      return false
    when 'v'
      @pc.go_south
    when '>'
      @pc.go_east
    when '<'
      @pc.go_west
    when '^'
      @pc.go_north
    when '#'
      @pc.move
    when '0'..'9'
      @stack.push instr.to_i
    end
    true
  end
end

machine = Machine.new(program)
result = machine.eval
if options[:summary]
  puts "ret:#{result}"
  puts "cnt:#{machine.instruction_count}"
end