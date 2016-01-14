require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PdfAppender
    class Application < Rails::Application
        # Settings in config/environments/* take precedence over those specified here.
        # Application configuration should go into files in config/initializers
        # -- all .rb files in that directory are automatically loaded.

        # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
        # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
        # config.time_zone = 'Central Time (US & Canada)'

        # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
        # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
        # config.i18n.default_locale = :de

        # Do not swallow errors in after_commit/after_rollback callbacks.
        #config.active_record.raise_in_transactional_callbacks = true # Only for rails 4.2+

        def new_product(csv_entry)
            prod = Product.new
            prod.product_id = csv_entry['ID']
            prod.directory = csv_entry['Directory']
            prod.sds = csv_entry['SDS']
            prod.pds = csv_entry['PDS']
            prod.description = csv_entry['Description']
            prod.vendor_id = csv_entry['VENDOR']
            prod.vendor_name = csv_entry['Name']
            prod.sds_expiry = get_sds_expiry_date(prod.product_id)
            return prod
        end

        def get_sds_expiry_date(product_id)
            sql = "SELECT \"SDS Expiry Date\"
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\"
        WHERE No_ = #{ActiveRecord::Base.connection.quote(product_id)}"
            records_array = Navision.connection.select_all(sql)
            return records_array.first["SDS Expiry Date"]
        end
        config.after_initialize do
            csv_path = Rails.root.join('alchemy-info-tables', 'gen', 'NZ_ID_SDS_PDS_VENDOR_NAME.csv')
            puts "THE SERVER HAS STARTED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            prods = Array.new
            CSV.foreach(csv_path, :headers => true) do |csv_obj|
                prods << new_product(csv_obj)
            end
            # save the products
            Product.delete_all
            prods.each(&:save)
        end
    end
end
