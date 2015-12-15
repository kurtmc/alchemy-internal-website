#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'csv'


def transform(report_path, output_path)
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

    # Setup values
    result = Array.new
    result.push(new_titles)

    for i in 1...report_csv.size
        tmp = Array.new(mapping.size)
        for j in 0...original_titles.size
            new_title = mapping[original_titles[j]]
            new_index = ordering.index(new_title)

            value = ""
            if report_csv[i].size <= j
                value = ""
            else
                value = report_csv[i][j]

                # TODO hooks
            end
            tmp[new_index] = value
        end
        result.push(tmp)
    end

    CSV.open(output_path, "wb") do |csv|
        result.each { |row| csv << row }
    end
end

output_path = "ashland-report.csv"
report_path = "/home/kurt/alchemy-workspace/ashland/Mock Reports/Mock Reports (24).csv"

transform(report_path, output_path)
