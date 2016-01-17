class Price < ActiveRecord::Base
    belongs_to :customer

    def self.get_for_customer(customer_id)
        sql = "SELECT a.\"Item No_\", a.\"Unit of Measure Code\",  a.\"Minimum Quantity\", b.\"Unit Price\" AS \"Published Price\", b.\"Unit Cost\" AS \"Cost\", a.\"Unit Price\" AS \"Price\", a.\"Starting Date\", a.\"Ending Date\"
FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Sales Price\" as a
JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\" as b
on a.\"Item No_\" = b.No_
WHERE a.\"Sales Code\" = #{SqlUtils.escape(customer_id)}"
        records = SqlUtils.execute_sql(sql)
        prices = Array.new
        records.each { |record|
            prices << self.new_price(record)
        }
        return prices
    end

    def self.new_price(record)
        price = Price.new
        price.item_id = record["Item No_"]
        price.unit_measure = record["Unit of Measure Code"]
        price.min_quantity = record["Minimum Quantity"]
        price.published_price = record["Published Price"]
        price.cost = record["Cost"]
        price.price = record["Price"]
        price.start_date = record["Starting Date"]
        price.end_date = record["Ending Date"]
        return price
    end

    def get_start_date
        if self.start_date < Date.parse("1754-01-01")
            return "No date"
        end
        return self.start_date.strftime("%Y-%m-%d")
    end

    def get_end_date
        if self.end_date < Date.parse("1754-01-01")
            return "No date"
        end
        return self.end_date.strftime("%Y-%m-%d")
    end


end
