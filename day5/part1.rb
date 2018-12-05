input = File.read("input.txt").strip.chars
GAP = 'a'.ord - 'A'.ord

loop do
    found = false
    i = 0
    while i < (input.size-1) do
        if (input[i].ord - input[i+1].ord).abs == GAP
            found = true
            input.delete_at(i)
            input.delete_at(i) # i+1 is now i
        end
        i += 1
    end

    break unless found
end

puts "End input is: #{input.size} units"
