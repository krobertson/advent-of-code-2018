def addr(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] + newreg[ops[1]]
  newreg
end

def addi(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] + ops[1]
  newreg
end

def mulr(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] * newreg[ops[1]]
  newreg
end

def muli(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] * ops[1]
  newreg
end

def banr(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] & newreg[ops[1]]
  newreg
end

def bani(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] & ops[1]
  newreg
end

def borr(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] | newreg[ops[1]]
  newreg
end

def bori(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] | ops[1]
  newreg
end

def setr(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]]
  newreg
end

def seti(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = ops[0]
  newreg
end

def gtrr(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] > newreg[ops[1]] ? 1 : 0
  newreg
end

def gtir(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = ops[0] > newreg[ops[1]] ? 1 : 0
  newreg
end

def gtri(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] > ops[1] ? 1 : 0
  newreg
end

def eqrr(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] == newreg[ops[1]] ? 1 : 0
  newreg
end

def eqir(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = ops[0] == newreg[ops[1]] ? 1 : 0
  newreg
end

def eqri(ops, registers)
  newreg = registers.dup
  newreg[ops[2]] = newreg[ops[0]] == ops[1] ? 1 : 0
  newreg
end

instp = nil
instructions = []

File.read("input.txt").split("\n").each do |l|
  if l =~ %r{^#ip}
    instp = l.scan(%r{^#ip (\d)}).flatten.first.to_i
  else
    op, ia, ib, oa = l.scan(%r{(\w+) (\d+) (\d+) (\d+)}).flatten
    instructions << { op: op.to_sym, inst: [ia.to_i, ib.to_i, oa.to_i] }
  end
end

# here it is: index of register to set to 1, value to set, and if it is part 2
[ [0, 0, false], [0, 1, true]].each do |(iidx,iv,is_part2)|
  i = 0
  regs = Array.new(6) { 0 }
  regs[iidx] = iv
  until i > instructions.size do
    # execute handling
    regs[instp] = i
    newregs = send(instructions[i][:op], instructions[i][:inst], regs)
    regs = newregs
    i = newregs[instp]
    i += 1

    # part 2 involves looping a ton, but it regularly hits instruction 1
    if i == 1 && is_part2
      # Find the max register, it'll be our target. Some redditors it was the
      # last register, for me it was the second to last. So figure, just find
      # the highest.
      target = regs.max
      # Step from 1 to the target, find all values it is divisible by, and sum
      # them up.
      sum = 1.step(to: target).select { |d| target % d == 0 }.sum
      puts "part2: #{sum}"
      break
    end
  end
  puts "part1: #{regs[0]}" unless is_part2
end
