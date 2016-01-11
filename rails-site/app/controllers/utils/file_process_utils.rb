require 'rubygems'
require 'zip'

class FileProcessUtils
    def self.handle_bulk_processing(zipfile_name, input_files, output_directory, file_processor, app_controller)
        zipfile_path = "#{output_directory}/#{zipfile_name}"
        begin
            File.delete(zipfile_path)
        rescue
            # do nothing
        end
        new_filenames = Array.new
        input_files.each { |uploaded_io|
            # Write uploaded files
            filename = uploaded_io.original_filename
            File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
                file.write(uploaded_io.read)
            end

            # Process files
            file_processor.call(filename)
            new_filenames << filename
        }

        Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
            new_filenames.each do |filename|
                # Two arguments:
                # - The name of the file as it will appear in the archive
                # - The original file, including the path to find it
                file_path = "#{output_directory}/#{filename}"
                zipfile.add(filename, file_path)
            end
        end
        # Send files
        app_controller.send_file(File.join(zipfile_path))
    end
end
