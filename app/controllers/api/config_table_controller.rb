class Api::ConfigTableController < Api::ApiController
	def index
		key_values = ConfigTable.all
        respond_to do |format|
            format.json {
                render :json => key_values
            }
        end
	end

end