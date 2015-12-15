#!/usr/bin/env ruby

require 'rubygems'
require 'json'
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

mapping = JSON.parse(File.read(mapping_path))

print mapping["Company"]
