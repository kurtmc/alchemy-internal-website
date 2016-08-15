class Helper
	def self.check_db
		return ActiveRecord::Base.connection.table_exists? 'config_tables'
	end

	def self.setup(key, value)
		default = ConfigTable.new
		default.key = key
		default.value = value
		default.save
	end
end

if Helper.check_db
	Helper.setup('Terms of Use', 'Terms of Use need to be updated by an administrator.')
	#As needed more config values and a default value can be added here
	#Below is an example of usage
	#Both key and value should be user friendly
	#Helper.setup('Terms of Sale', 'Please insert terms of sale')
end
