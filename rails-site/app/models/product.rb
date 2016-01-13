require 'uri'

class Product < ActiveRecord::Base
    def get_product_id
        return self.product_id.gsub('/',"%2F").gsub('%', "%25")
    end

    def get_sds_expiry_formatted
        if self.sds_expiry.nil?
            return 'EXPIRED!'
        end
        return self.sds_expiry.strftime("%Y-%m-%d")
    end

    def update_fields
        self.sds_expiry = Product.get_sds_expiry_date(self.product_id)
    end

    def self.get_sds_expiry_date(product_id)
        sql = "SELECT \"SDS Expiry Date\"
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\"
        WHERE No_ = #{ActiveRecord::Base.connection.quote(product_id)}"
        records_array = Navision.connection.select_all(sql)
        return records_array.first["SDS Expiry Date"]
    end

end
