require 'rubygems'
require 'json'
require 'csv'

class AshlandController < ApplicationController
    def new
    end

    def show
    end

    def create
        if params[:ashland].nil?
            render 'new'
            return
        end
        uploaded_io = params[:ashland][:csv_file]
        filename = uploaded_io.original_filename
        report_path = Rails.root.join('public', 'uploads', filename)
        File.open(report_path, 'wb') do |file|
            file.write(uploaded_io.read)
        end

        output_path = Rails.root.join('public', 'uploads', 'ashland-report.csv')

        transform(report_path, output_path)

        send_file(output_path)
    end

    def transform(report_path, output_path)
        ordering_path = Rails.root.join('ashland-report', 'Ordering')
        mapping_path = Rails.root.join('ashland-report', 'Mapping')
            
        report_csv =  CSV.read(report_path)
        original_titles = report_csv[0]

        ordering = File.readlines(ordering_path)
        ordering.map do |line|
            line.strip!
        end

        mapping = JSON.parse(File.read(mapping_path))

        # Get new titles
        new_titles = Array.new(mapping.size)
        (0...original_titles.size).each { |i|
            new_title = mapping[original_titles[i]]
            new_index = ordering.index(new_title)
            unless new_title.nil? or new_title.empty?
                new_titles[new_index] = new_title
            end
        }

        # Setup values
        result = Array.new
        result.push(new_titles)

        (1...report_csv.size).each { |i|
            tmp = Array.new(mapping.size)
            (0...original_titles.size).each { |j|
                new_title = mapping[original_titles[j]]
                new_index = ordering.index(new_title)

                if report_csv[i].size <= j
                    value = ''
                else
                    value = report_csv[i][j]

                    # TODO hooks
                end
                tmp[new_index] = value
            }
            result.push(tmp)
        }

        CSV.open(output_path, 'wb') do |csv|
            result.each { |row| csv << row }
        end
    end

end
