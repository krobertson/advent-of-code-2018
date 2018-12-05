freq = 0

File.read("input.txt").split("\n").each do |l|
    freq = freq + l.to_i
end

puts freq
