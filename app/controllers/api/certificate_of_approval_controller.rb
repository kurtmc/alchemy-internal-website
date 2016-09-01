class Api::CertificateOfApprovalController < Api::ApiController

    # The coa's must be places at RAILS_ROOT/coa
    def get_coa

        begin
            res = nil
            coa_id = params[:cod_id]

            if coa_id.blank?
                raise('COA number cannot be blank.')
            end

            if coa_id.include? '*'
                raise('* is an invalid character, please give COA number.')
            end

            coa_path = Dir["#{Rails.root.join('coa', "#{coa_id}")}.{pdf,PDF}"][0]

            if res.nil? && !coa_path.blank? && File.file?(coa_path)
                send_file(coa_path)
            else
                raise("COA '#{coa_id}' could not be found.")
            end
        rescue Exception => e
            puts e.inspect
            respond_to do |format|
                format.json {
                    render :json => {
                        "result" => "failure",
                        "message" => e.message
                    }
                }
            end
        end


    end

end
