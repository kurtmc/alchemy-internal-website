class SdsController < ApplicationController
    def new
    end

    def create
        if params[:pdf].nil?
            render 'new'
            return
        end
        uploaded_io = params[:pdf][:pdf_file]
        filename = uploaded_io.original_filename
        File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
            file.write(uploaded_io.read)
        end
        #redirect_to pdfs_path
        cmd = 'cd sds_header_pdf; ./run.sh "../public/uploads/' + filename + '"'
        `#{cmd}`
        #render plain: cmd + ':::::::' + value
        #render plain: `pwd`
        send_file(File.join(Rails.root, 'sds_header_pdf', 'output', filename))
    end
end
