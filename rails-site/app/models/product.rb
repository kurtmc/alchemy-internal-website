class Product < ActiveRecord::Base
    def get_product_id
        return self.product_id.gsub('/',"%2F")
    end
end
