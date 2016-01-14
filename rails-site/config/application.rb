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

        config.autoload_paths += %W(#{config.root}/lib)

        ## Initialistaion code
        def new_product(csv_entry)
            prod = Product.new
            prod.product_id = csv_entry['ID']
            prod.directory = csv_entry['Directory']
            prod.sds = csv_entry['SDS']
            prod.pds = csv_entry['PDS']
            prod.description = csv_entry['Description']
            prod.vendor_id = csv_entry['VENDOR']
            prod.vendor_name = csv_entry['Name']
            prod.update_fields
            return prod
        end

        def load_products
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

        def load_customers
            Customer.load_all
        end

        config.after_initialize do
            load_products
            load_customers
        end
    end
end
