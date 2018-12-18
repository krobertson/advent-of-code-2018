ITERATIONS = 1_000_000_000

CONVERT = {
  "." => :open,
  "|" => :trees,
  "#" => :lumber,
}
BACK = CONVERT.invert

NEIGHBORS = [ [1, 0], [0, 1], [-1, 0], [0, -1], [1, 1], [-1, -1], [1, -1], [-1, 1] ]

# Load and convert
lines = File.read("input.txt").split("\n")
matrix = Array.new(lines.count) { [] }
lines.each_with_index do |l,i|
  l.chars.each do |c|
    matrix[i] << CONVERT[c]
  end
end

def printit(matrix)
  matrix.each do |row|
    row.each { |c| print BACK[c] }
    puts
  end
end

def walk_neighbors(matrix, x, y)
  sums = Hash.new { |h,k| h[k] = 0 }
  NEIGHBORS.each do |(diffx, diffy)|
    next if matrix[y].size <= x+diffx || x+diffx < 0
    next if matrix.size <= y+diffy || y+diffy < 0
    sums[matrix[y+diffy][x+diffx]] += 1
  end
  sums
end

def determine_new(matrix, x, y)
  sums = walk_neighbors(matrix, x, y)
  case matrix[y][x]
  when :open
    return :trees if sums[:trees] >= 3
    return :open
  when :trees
    return :lumber if sums[:lumber] >= 3
    return :trees
  when :lumber
    return :lumber if sums[:lumber] >= 1 && sums[:trees] >= 1
    return :open
  else
    return matrix[y][x]
  end
end

def build_new(matrix)
  new_matrix = Array.new(matrix.size) { [] }
  matrix.each_with_index do |row,y|
    row.each_with_index do |c,x|
      n = determine_new(matrix, x, y)
      new_matrix[y] << n
    end
  end
  new_matrix
end

def count_types(matrix)
  sums = Hash.new { |h,k| h[k] = 0 }
  matrix.each do |row|
    row.each { |c| sums[c] += 1 }
  end
  sums
end


puts "Initial"
printit matrix
puts

# Handling for part 2. We'll pay attention to when the number of trees peaks,
# and look for a pattern. When we hit the same peak 3 times, we know the time
# between the last two ocurrances is our iteration time. First first one is the
# baseline, so it is ignored.
prev_trees = 0
trees_mode = :climbing
tree_history = Hash.new { |h,k| h[k] = [] }
quit_at = nil

ITERATIONS.times do |i|
  matrix = build_new(matrix)

  t = count_types(matrix)

  # Print for part 1 and quit when we know when we have part 2
  if i == 9 || i == quit_at
    v = t[:trees] * t[:lumber]
    puts "Value: #{v} -- #{i+1} minutes"
    break if i == quit_at
  end

  # manually step
  # puts "\e[H\e[2J"
  # puts "#{i+1} iteration"
  # printit matrix
  # puts t.sort.inspect
  # STDIN.gets

  # Check if we've peaked
  if t[:trees] < prev_trees && trees_mode == :climbing
    trees_mode = :dropping

    tree_history[t[:trees]] << i
    hist = tree_history[t[:trees]]

    # If we have 3 instances, we can now calculate at what interval we can quit at
    if hist.size == 3 && quit_at == nil
      iter_size = hist[2] - hist[1]
      quit_at = i + ((ITERATIONS - i) % iter_size) - 1
    end
  end

  # Detect the valley
  trees_mode = :climbing if t[:trees] > prev_trees && trees_mode == :dropping

  prev_trees = t[:trees]
end
