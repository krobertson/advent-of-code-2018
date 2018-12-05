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

asleep_minutes = guards_sleep.inject({}) do |s,(id,mins)|
  s[id] = mins.values.sum
  s
end

most_sleep = asleep_minutes.max_by { |k,v| v }.first
min, count = guards_sleep[most_sleep].max_by { |k,v| v }

puts "Guard #{most_sleep} was asleep the most"
puts "Most asleep at #{min} a total of #{count} times"
puts "Value: #{min * most_sleep.to_i}"
