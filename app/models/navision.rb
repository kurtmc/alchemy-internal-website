class Navision < ActiveRecord::Base
    unless Rails.env.test?
        establish_connection "navision"
    end
end
