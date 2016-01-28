class Api::ProductsController < ActionController::Base
    def authenticate_json_user!
        user = User.find_by_email(params[:user][:email])
        unless user.valid_password?(params[:user][:password]) && user.api_user?
            raise SecurityError
        end
    end

    before_filter :authenticate_json_user!

    def index
        @products = Product.all.order :product_id
        respond_to do |format|
            format.json {
                if params[:csv] == 'true'
                    render text: get_products_csv
                else
                    render json: @products
                end
            }
        end
    end

    def show
        respond_to do |format|
            format.json { render json: Product.find(params[:id])}
        end
    end

    def get_products_csv
        mapping = Hash.new
        mapping['id'] = 'id'
        mapping['product_id'] = 'product_id'
        mapping['directory'] = 'directory'
        mapping['sds'] = 'sds'
        mapping['pds'] = 'pds'
        mapping['vendor_id'] = 'vendor_id'
        mapping['vendor_name'] = 'vendor_name'
        mapping['description'] = 'product_name'
        mapping['description2'] = 'pack_size'
        mapping['new_description'] = 'description'
        
        csv_string = CSV.generate do |csv|
            csv << mapping.values
            all_products = Product.select(mapping.keys)
            all_products.each do |product|
                csv << product.attributes.values
            end
        end
    end
end
