class Product < ActiveRecord::Base
    def get_product_id
        return self.product_id.gsub('/',"%2F").gsub('%', "%25")
    end

    def get_sds_expiry
        sql = "SELECT \"SDS Expiry Date\"
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\"
        WHERE No_ = #{ActiveRecord::Base.connection.quote(self.product_id)}"
        records_array = Navision.connection.select_all(sql)
        return records_array.first["SDS Expiry Date"]
    end

end
