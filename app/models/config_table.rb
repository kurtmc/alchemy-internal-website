class ConfigTable < ActiveRecord::Base
	validates :key, uniqueness: true
end
