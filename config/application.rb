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


        config.after_initialize do
            # Cache Navision database in a new thread
            Thread.new do
                Product.load_all
                SalesPerson.load_all
                Customer.load_all
                Vendor.load_all
                ActiveRecord::Base.connection.close
            end
            puts "Server start"
        end
    end
end
