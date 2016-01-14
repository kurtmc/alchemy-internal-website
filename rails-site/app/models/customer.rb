
class Customer < ActiveRecord::Base
    belongs_to :salesperson
    include SqlUtils

    def self.load_all
        puts "Loading all customers!"
        sql = "SELECT *
      FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\""
        records = SqlUtils.execute_sql(sql)
        puts records.first.inspect
        customers = Array.new
        records.each { |customer_record|
            customer = Customer.new
            customer.customer_id = customer_record["No_"]
            customer.name = customer_record["Name"]
            customers << customer
        }
        # save the products
        Customer.delete_all
        customers.each(&:save)
    end

    def update_fields
        sql = "SELECT *
      FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\"
      WHERE No_ = #{SqlUtils.escape(self.customer_id)}"
        records = SqlUtils.execute_sql(sql)
        self.name = records["Name"]
        #TODO find these
        #self.balance = records[]
        #self.credit_limit = records[]
        #self.last_1_to_30 = records[]
        #self.last_31_to_60 = records[]
        #self.last_31_90 = records[]
        #self.last_90_plus = records[]
    end

end
