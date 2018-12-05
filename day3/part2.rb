s = 1000
graph = Array.new(s) { Array.new(s) }

## #1 @ 829,837: 11x22
format = %r{#(?<id>\d+)\s@\s(?<starty>\d+),(?<startx>\d+):\s(?<sizey>\d+)x(?<sizex>\d+)}

clashes = {}
lines = File.read("input.txt").split("\n")

lines.each do |l|
    matches = l.match(format)
    raise "oops" if matches.nil?

    startx = matches[:startx].to_i
    starty = matches[:starty].to_i

    (0...matches[:sizex].to_i).each do |xi|
        (0...matches[:sizey].to_i).each do |yi|
            if graph[startx+xi][starty+yi] == nil
                graph[startx+xi][starty+yi] = matches[:id]
            else
                # clashes += graph[startx+xi][starty+yi] == "X" ? 2 : 1
                clashes[[startx+xi, starty+yi]] = true
                graph[startx+xi][starty+yi] = "X"
            end
        end
    end
end

lines.each do |l|
    matches = l.match(format)
    raise "oops" if matches.nil?

    startx = matches[:startx].to_i
    starty = matches[:starty].to_i

    valid = true
    (0...matches[:sizex].to_i).each do |xi|
        (0...matches[:sizey].to_i).each do |yi|
            valid = false if graph[startx+xi][starty+yi] == "X"
        end
    end

    puts "Claim #{matches[:id]} was still valid" if valid
end
