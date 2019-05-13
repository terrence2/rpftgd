#!/bin/env ruby

require 'optparse'

OPTIONS = {}
OptionParser.new do |opts|
  opts.banner = "Usage: befunge.rb [OPTIONS] <program.bf>"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    OPTIONS[:verbose] = v
  end
  opts.on("-s", "--summary", "Show summary after completion") do |v|
    OPTIONS[:summary] = v
  end
end.parse!

fp = File::open(ARGV.first)
lines = fp.readlines.map(&:rstrip)
fp.close

max_line_length = lines.map(&:length).max

program = lines.map do |line|
  program_row = []
  line.chars.map do |c|
    program_row.push(c.ord)
  end
  while program_row.length() < max_line_length
    program_row.push(' '.ord)
  end
  program_row
end

class InstructionPointer
  def initialize(width, height)
    @x = 0
    @y = 0
    @dx = 1
    @dy = 0
    @width = width
    @height = height
  end

  def move_next
    @x += @dx
    @y += @dy
    @x %= @width
    @y %= @height
  end

  def go_south
    @dx = 0
    @dy = 1
  end

  def go_north
    @dx = 0
    @dy = -1
  end

  def go_east
    @dx = 1
    @dy = 0
  end

  def go_west
    @dx = -1
    @dy = 0
  end

  def go_random
    case rand(4)
    when 0
      go_north
    when 1
      go_south
    when 2
      go_east
    when 3
      go_west
    end
  end

  def access(memory)
    memory[@y][@x]
  end

  def show
    "@#{@x}x#{@y}>#{@dx}x#{@dy}"
  end
end

class Machine
  attr_accessor :instruction_count

  def initialize(program)
    @instruction_count = 0
    @ip = InstructionPointer.new(program[0].length, program.length)
    @memory = program
    @stack = []
  end

  def push_stack(v)
    @stack.push(v)
  end

  def pop_stack
    @stack.pop || 0
  end

  def eval
    while true
      @instruction_count += 1
      if !exec_one_instruction
        break
      end
      @ip.move_next
    end
    pop_stack
  end

  def exec_one_instruction
    instr = @ip.access(@memory)
    if OPTIONS[:verbose]
      puts "At #{@ip.show}: #{instr.chr}"
    end
    case instr.chr
    when '@'
      return false
    when 'v'
      @ip.go_south
    when '^'
      @ip.go_north
    when '<'
      @ip.go_west
    when '>'
      @ip.go_east
    when '#'
      @ip.move_next
    when '?'
      @ip.go_random
    when '0'..'9'
      push_stack(instr.chr.to_i)
    when '$'
      pop_stack
    when '\\'
      a = pop_stack
      b = pop_stack
      push_stack(a)
      push_stack(b)
    when ':'
      a = pop_stack
      push_stack(a)
      push_stack(a)
    when '+'
      a = pop_stack
      b = pop_stack
      push_stack(b + a)
    when '-'
      a = pop_stack
      b = pop_stack
      push_stack(b - a)
    when '*'
      a = pop_stack
      b = pop_stack
      push_stack(b * a)
    when '/'
      a = pop_stack
      b = pop_stack
      push_stack(b / a)
    when '%'
      a = pop_stack
      b = pop_stack
      push_stack(b % a)
    when '`'
      a = pop_stack
      b = pop_stack
      push_stack(b > a ? 1 : 0)
    when '!'
      push_stack(pop_stack != 0 ? 0 : 1)
    when '_'
      v = pop_stack
      if v == 0
        @ip.go_east
      else
        @ip.go_west
      end
    when '|'
      v = pop_stack
      if v == 0
        @ip.go_south
      else
        @ip.go_north
      end
    when 'g'
      y = pop_stack
      x = pop_stack
      push_stack(@memory.fetch(y, []).fetch(x, 0))
    when 'p'
      y = pop_stack
      x = pop_stack
      v = pop_stack
      @memory[y][x] = v
    when '.'
      v = pop_stack
      print "#{v}\n"
    when ','
      v = pop_stack
      print "#{v.chr}"
    end
    true
  end
end

machine = Machine.new(program)
result = machine.eval

if OPTIONS[:summary]
  puts "ret:#{result}"
  puts "cnt:#{machine.instruction_count}"
end
