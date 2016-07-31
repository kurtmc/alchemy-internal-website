require 'fileutils'

class Document < ActiveRecord::Base
    belongs_to :document_type
    belongs_to :product

    def absolute_path
        if self.absolute_directory.blank?
            return nil
        end
        if self.filename.blank?
            return nil
        end

        return File.join(self.absolute_directory, self.filename)
    end

    def delete_file
        if self.absolute_path.blank?
            return
        end

        # Remove file
        begin
            FileUtils.rm(self.absolute_path)
        rescue
            puts "Failed to delete file"
            return
        end
        
        # Commit
        cmd = 'cd alchemy-info-tables; '
        cmd += 'git add . 2>&1; '
        cmd += 'git commit -m "Removed document" 2>&1'
        `#{cmd}`
    end
end
