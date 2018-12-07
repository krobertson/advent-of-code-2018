input = File.read("input.txt").split("\n")

steps = Hash.new { |h,k| h[k] = [] }

input.each do |line|
  pre, post = line.scan(%r{Step (\w) must be finished before step (\w) can begin}).flatten
  steps[pre] ||= []
  steps[post] << pre
end

# find steps with no prereqs
order = []
while steps.any?
  next_step = steps.select { |k,v| v.empty? }.sort.first.first
  order << next_step
  steps.delete(next_step)
  steps.keys.each do |k|
    steps[k] -= [next_step]
  end
end

puts order.join
