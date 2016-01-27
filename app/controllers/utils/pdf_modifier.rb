require 'utils/file_process_utils'
class PdfModifier

    def self.modify_pdf(pdf_files, template, landscape, app_controller)
        output_directory = Rails.root.join('pdf_modifier', 'output')
        zipfile_name = 'output.zip'
        file_processor = Proc.new do |filename|
            cmd = 'cd pdf_modifier;'
            cmd += './run.sh '
            if landscape
                cmd += '-l '
            end
            cmd += "-t #{template} \"../public/uploads/#{filename}\""
            `#{cmd}`
        end
        FileProcessUtils.handle_bulk_processing(zipfile_name, pdf_files, output_directory, file_processor, app_controller)
    end

end
