require 'rubygems'
require 'zip'

class SdsController < ApplicationController
    def new
    end

    def create
        if params[:pdf].nil?
            render 'new'
            return
        end
        zipfile_name = Rails.root.join('sds_header_pdf', 'output', 'output.zip')
        begin
            File.delete(zipfile_name) # Initially delete output.zip
        rescue
            # do nothing
        end
        new_filenames = Array.new
        pdf_files = params[:pdf][:pdf_files]
        pdf_files.each { |uploaded_io|
            filename = uploaded_io.original_filename
            File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
                file.write(uploaded_io.read)
            end
            #redirect_to pdfs_path
            cmd = 'cd sds_header_pdf; ./run.sh "../public/uploads/' + filename + '"'
            `#{cmd}`
            new_filenames << filename
        }
        directory = Rails.root.join('sds_header_pdf', 'output')

        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
            new_filenames.each do |filename|
                # Two arguments:
                # - The name of the file as it will appear in the archive
                # - The original file, including the path to find it
                zipfile.add(filename, "#{directory}/#{filename}")
            end
            zipfile.get_output_stream("myFile") { |os| os.write "myFile contains just this" }
        end
        # Send files
        send_file(File.join(zipfile_name))
    end
end
