require 'utils/file_process_utils'

class PdfsController < ApplicationController
    def new
    end

    def create
        if params[:pdf].nil?
            render 'new'
            return
        end

        output_directory = Rails.root.join('footer_pdf', 'output')
        zipfile_name = 'output.zip'
        pdf_files = params[:pdf][:pdf_files]
        file_processor = Proc.new do |filename|
            cmd = 'cd footer_pdf; ./run.sh "../public/uploads/' + filename + '"'
            `#{cmd}`
        end
        FileProcessUtils.handle_bulk_processing(zipfile_name, pdf_files, output_directory, file_processor, self)
    end
end
