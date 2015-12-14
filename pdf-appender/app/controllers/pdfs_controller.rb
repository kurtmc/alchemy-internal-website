class PdfsController < ApplicationController
    def new
    end

    def create
        uploaded_io = params[:pdf][:pdf_file]
        filename = uploaded_io.original_filename
        File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
            file.write(uploaded_io.read)
        end
        #redirect_to pdfs_path
        cmd = 'cd footer_pdf; ./run.sh "../public/uploads/' + filename + '"'
        value = `#{cmd}`
        #render plain: cmd + ':::::::' + value
        #render plain: `pwd`
        send_file(File.join(Rails.root, "footer_pdf", "output", filename))
    end
end
