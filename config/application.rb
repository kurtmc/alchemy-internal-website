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

        # Email configuration options
        config.action_mailer.default_url_options = { 
            :host => 'alchemyagencies.co.nz'
        }
        config.action_mailer.delivery_method = :smtp
        config.action_mailer.smtp_settings = {
            address: "mail.example.com",
            port: 110, #I'm not sure if the port need to be 25 or 110... it depends of which port your Exchange listens, usually 25, but there are strong recommendations to use 110, letting port 25 free for smtp communication between smtp servers only.
            domain: "my.domainame.com",
            authentication: :ntlm,
            enable_starttls_auto: true,
            user_name: "my_username",
            password: "my_password"
        }

    end
end
