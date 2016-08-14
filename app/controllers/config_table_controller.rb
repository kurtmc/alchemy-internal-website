class ConfigTableController < ApplicationController
	def index
		create_default_values
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

	#This should probably be moved into an initialiser method once there are more
	#than a single key in the table
	def create_default_values
		#Terms of use
		@default = ConfigTable.new
		@default.key = 'Terms of Use'
		@default.value = 'Need to be updated'
		@default.save
	end

end
