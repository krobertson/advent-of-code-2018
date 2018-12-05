guards_sleep = Hash.new { |h,k| h[k] = Hash.new(0) }

current_guard = nil
begin_minute = nil

File.read("input2.txt").split("\n").each do |line|
  minute = line.scan(%r{\d{2}:(\d{2})}).flatten.first.to_i

  # set gaurd
  if line =~ /begins shift/
    current_guard = line.scan(%r{Guard #(\d+)}).flatten.first
    next
  end

  if line =~ /falls asleep/
    begin_minute = minute
    next
  end

  if line =~ /wakes up/
    (begin_minute...minute).each { |m| guards_sleep[current_guard][m] += 1 }
  end
end

most_freq = guards_sleep.max_by { |k,v| v.max_by { |j,k| k }.last }.first
min, count = guards_sleep[most_freq].max_by { |j,k| k }

puts "Guard #{most_freq} is most frequently asleep in min #{min} a total of #{count} times"
puts "Value: #{most_freq.to_i * min}"
