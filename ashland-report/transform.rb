#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'csv'

report_path = "/home/kurt/alchemy-workspace/ashland/Mock Reports/Mock Reports Simple.csv"
ordering_path = "Ordering"
mapping_path = "Mapping"
    
report_csv =  CSV.read(report_path)
original_titles = report_csv[0]

ordering = File.readlines(ordering_path)
ordering.map do |line|
    line.strip!
end

mapping = JSON.parse(File.read(mapping_path))

# Get new titles
new_titles = Array.new(mapping.size)
for i in 0...original_titles.size
    new_title = mapping[original_titles[i]]
    new_index = ordering.index(new_title)
    unless new_title.nil? or new_title.empty?
        new_titles[new_index] = new_title
    end
end

print new_titles
