class ApplicationController < ActionController::Base
    before_filter :authenticate_user!
    before_filter :authenticate_web_user!
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :exception

    # restrict access to admin module for non-admin users
    def authenticate_admin_user!
        if current_user.nil?
            raise SecurityError
        end
        unless current_user.admin == true
            raise SecurityError
        end
    end

    # Authenticate website users
    def authenticate_web_user!
        unless current_user.nil?
            if current_user.api_user?
                render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
            end
        end
    end

    rescue_from SecurityError do |exception|
        render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end

    # Reload all tables
    def self.load_all_tables
        Product.load_all
        Vendor.load_all
        SalesPerson.load_all
        Customer.load_all
        Agency.load_all
    end

    # Delete all tables
    def self.delete_all_tables
        Product.delete_all
        Vendor.delete_all
        SalesPerson.delete_all
        Customer.delete_all
        Agency.delete_all
    end
end
