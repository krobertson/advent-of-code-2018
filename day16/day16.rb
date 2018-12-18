require 'set'

initial = File.read("input.txt").split("\n\n\n")

conditions = []
initial[0].split("\n\n").each do |line|
  cd = {}
  line.split("\n").each do |l|
    if l =~ %r{^Before}
      cd[:before] = l.scan(%r{^Before: \[(\d+), (\d+), (\d+), (\d+)\]}).flatten.map(&:to_i)
    elsif l =~ %r{^After}
      cd[:after] = l.scan(%r{^After:  \[(\d+), (\d+), (\d+), (\d+)\]}).flatten.map(&:to_i)
    else
      cd[:instructions] = l.scan(%r{^(\d+) (\d+) (\d+) (\d+)}).flatten.map(&:to_i)
    end
  end
  conditions << cd
end

all_ops = %i{addr addi mulr muli banr bani borr bori setr seti gtrr gtir gtri eqrr eqri eqir}

def addr(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] + newreg[ops[2]]
  newreg
end

def addi(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] + ops[2]
  newreg
end

def mulr(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] * newreg[ops[2]]
  newreg
end

def muli(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] * ops[2]
  newreg
end

def banr(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] & newreg[ops[2]]
  newreg
end

def bani(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] & ops[2]
  newreg
end

def borr(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] | newreg[ops[2]]
  newreg
end

def bori(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] | ops[2]
  newreg
end

def setr(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]]
  newreg
end

def seti(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = ops[1]
  newreg
end

def gtrr(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] > newreg[ops[2]] ? 1 : 0
  newreg
end

def gtir(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = ops[1] > newreg[ops[2]] ? 1 : 0
  newreg
end

def gtri(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] > ops[2] ? 1 : 0
  newreg
end

def eqrr(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] == newreg[ops[2]] ? 1 : 0
  newreg
end

def eqir(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = ops[1] == newreg[ops[2]] ? 1 : 0
  newreg
end

def eqri(ops, registers)
  newreg = registers.dup
  newreg[ops[3]] = newreg[ops[1]] == ops[2] ? 1 : 0
  newreg
end

over = 0

puts "Conditions: #{conditions.size}"

conditions.each do |cd|
  same = 0

  same += 1 if addr(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if addi(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if mulr(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if muli(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if setr(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if seti(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if banr(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if bani(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if borr(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if bori(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if gtrr(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if gtri(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if gtir(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if eqrr(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if eqri(cd[:instructions], cd[:before]) == cd[:after]
  same += 1 if eqir(cd[:instructions], cd[:before]) == cd[:after]

  over += 1 if same >= 3
end

puts "Num over 3: #{over}"


# part2
opcodes = {}
ops_pos = Hash.new { |h,k| h[k] = Set.new }
conditions.each do |cd|
  all_ops.each do |f|
    if send(f, cd[:instructions], cd[:before]) == cd[:after]
      ops_pos[cd[:instructions].first] << f
    end
  end
end

# find the mappings and reduce possibilities until done
loop do
  break if ops_pos.empty?
  n = ops_pos.select { |k,v| v.size == 1 }
  if n.size == 0
    puts "crap -- #{ops_pos.inspect}"
    exit 0
  end
  n.keys.each do |k|
    f = n[k].first
    opcodes[k] = f
    ops_pos.delete(k)
    ops_pos.each { |k,v| ops_pos[k] = v - [f] }
  end
end
puts opcodes.inspect

# run instructions
regs = [0, 0, 0, 0]
initial[1].strip.split("\n").each do |l|
  inst = l.scan(%r{^(\d+) (\d+) (\d+) (\d+)}).flatten.map(&:to_i)
  regs = send(opcodes[inst[0]], inst, regs)
end
puts regs.inspect
