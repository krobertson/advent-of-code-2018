freq = 0
seen = {}

loop do
    puts "Reading"
    File.read("input.txt").split("\n").each do |l|
        freq = freq + l.to_i

        if seen[freq]
            puts "Encountered #{freq} twice"
            exit 0
        end

        seen[freq] = true
    end
end
