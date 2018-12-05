ids = File.read("input.txt").split("\n")

def compare(a, b)
    ac = a.chars
    bc = b.chars
    diff = 0
    (0...ac.count).each do |i|
        diff += 1 if ac[i] != bc[i]
    end
    diff
end

def merge(a, b)
    ac = a.chars
    bc = b.chars
    str = ""
    (0...ac.count).each do |i|
        str += ac[i] if ac[i] == bc[i]
    end
    str
end


ids.each_with_index do |a, i|
    ((i+1)...ids.count).each do |k|
        b = ids[k]

        diff = compare(a, b)

        if diff == 1
            puts "#{a} is one off from #{b}"
            puts merge(a, b)
        end
    end
end
