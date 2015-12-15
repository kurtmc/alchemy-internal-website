#!/usr/bin/env ruby

require 'csv'

report_path = "/home/kurt/alchemy-workspace/ashland/Mock Reports/Mock Reports Simple.csv"
ordering_path = "Ordering"
mapping_path = "Mapping"
    
report_csv =  CSV.read(report_path)
report_titles = report_csv[0]

ordering = File.readlines(ordering_path)
ordering.map do |line|
    line.strip!
end

print ordering
