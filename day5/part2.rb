start_input = File.read("input.txt").strip.chars
GAP = 'a'.ord - 'A'.ord

def process(input)
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
    input
end

tries = {}
(65..90).each do |base|
    pos = start_input.dup.delete_if { |c| c == base.chr || c == (base + GAP).chr }
    pos = process(pos)
    tries[base.chr + (base+GAP).chr] = pos.length
    puts "Did #{base.chr + (base+GAP).chr} with size #{pos.length}"
end

mins = tries.min_by { |k,v| v }
puts mins.inspect
