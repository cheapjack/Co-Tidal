#!/bin/ruby

require 'json'

global_max_height = 0.0
global_min_height = 1000.0

Dir.glob('*.json') do |json_file|
  file = File.read(json_file)
  
  data = JSON.parse(file)
  
  max_height = 0.0
  min_height = 1000.0
  data.each do |d|
    height = d["height"]
    if height > max_height
      max_height = height
    end
    if height < min_height
      min_height = height
    end
  end
  puts "### #{json_file}"
  puts "max: #{max_height}"
  puts "min: #{min_height}"
  puts "range: #{(max_height-min_height)}"
  puts
  # Check for globals
  if max_height > global_max_height
    global_max_height = max_height
  end
  if min_height < global_min_height
    global_min_height = min_height
  end
end

puts "### Global"
puts "max: #{global_max_height}"
puts "min: #{global_min_height}"
puts "range: #{(global_max_height-global_min_height)}"
