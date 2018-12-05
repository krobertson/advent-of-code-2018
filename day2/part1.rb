total_has2 = 0
total_has3 = 0

File.read("input.txt").split("\n").each do |l|
    h = Hash.new { |h,k| h[k] = 0 }
    l.chars.each do |c|
        h[c] += 1
    end

    has2 = false
    has3 = false

    h.values.each do |v|
        has2 = true if v == 2
        has3 = true if v == 3
    end

    total_has2 += 1 if has2
    total_has3 += 1 if has3
end

puts "Count that had two: #{total_has2}"
puts "Count that had three: #{total_has3}"
puts "Checksum: #{total_has2 * total_has3}"
