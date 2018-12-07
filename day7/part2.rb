input = File.read("input.txt").split("\n")

WORKERS = 5
BASE = 60

STEPS = Hash.new { |h,k| h[k] = [] }

input.each do |line|
  pre, post = line.scan(%r{Step (\w) must be finished before step (\w) can begin}).flatten
  STEPS[pre] ||= []
  STEPS[post] << pre
end

class Worker
  def initialize(id)
    @id = id
    @remaining = 0
    @current = ''
  end

  def work
    # have no work, see if we can grab some
    if @remaining == 0
      return false unless self.get_work # no work is available
      puts "  #{@id} Pulled #{@current}"
    end

    # tick
    @remaining -= 1
    puts "  #{@id} has #{@remaining} remaining on #{@current}"
    puts "  #{@id} Finshed #{@current}" if @remaining == 0
    true
  end

  def get_work
    next_step = STEPS.select { |k,v| v.empty? }.sort.first&.first
    return false if next_step.nil?
    STEPS.delete(next_step)

    @current = next_step
    @remaining = @current.ord - 64 + BASE
    true
  end

  def done
    if @remaining == 0
      STEPS.keys.each do |k|
        STEPS[k] -= [@current]
      end
    end
  end
end

puts STEPS.inspect

workers = WORKERS.times.collect { |i| Worker.new(i) }

# seconds work loop
seconds = 0
loop do
  puts "#{seconds} " + "="*30
  result = workers.collect { |w| w.work }
  break if result.all? { |r| r == false }
  seconds += 1

  # done is called sepately to avoid finishing a step and pulling the next one
  # in the same iteration
  workers.each { |w| w.done }
end
puts "Total seconds: #{seconds}"
