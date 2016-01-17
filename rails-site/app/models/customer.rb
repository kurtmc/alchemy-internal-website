
class Customer < ActiveRecord::Base
    belongs_to :salesperson
    has_many :prices
    include SqlUtils

    def self.load_all
        SalesPerson.all.each { |person|
            sql = "SELECT *
          FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\"
          WHERE \"Salesperson Code\" = #{SqlUtils.escape(person.salesperson_code)}"
            records = SqlUtils.execute_sql(sql)
            puts records.first.inspect
            records.each { |customer_record|
                customer = Customer.new
                customer.customer_id = customer_record["No_"]
                customer.update_fields
                customer.save
            }
        }
    end

    def update_fields
        sql = "SELECT *
      FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\"
      WHERE No_ = #{SqlUtils.escape(self.customer_id)}"
        records = SqlUtils.execute_sql(sql).first
        self.name = records["Name"]
        #TODO find these
        #self.balance = records[]
        #self.credit_limit = records[]
        #self.last_1_to_30 = records[]
        #self.last_31_to_60 = records[]
        #self.last_31_90 = records[]
        #self.last_90_plus = records[]
        person = SalesPerson.find_by salesperson_code: records["Salesperson Code"]
        self.salesperson_id = person.id
        self.save
    end

    def get_prices
        prices = Price.get_for_customer(self.customer_id)
        return prices
    end

end
