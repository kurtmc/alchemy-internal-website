class ConfigTableController < ApplicationController
	def index
		@key_values = ConfigTable.all
	end

	def edit
		@key_value = ConfigTable.find(params[:id])
	end

	def update
		@key_value = ConfigTable.find(params[:id])
		update_fields
        redirect_to action: "index"
	end

	def update_fields
		@key_value.value = params[:config_table][:value]
		@key_value.save
	end

end
