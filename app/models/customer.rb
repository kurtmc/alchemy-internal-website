
class Customer < ActiveRecord::Base
    belongs_to :salesperson
    has_many :prices
    include SqlUtils

    def self.load_all
        Customer.delete_all
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
        self.balance = get_balance
        self.credit_limit = records["Credit Limit (LCY)"]
        self.current = get_current
        self.last_1_to_30 = get_range(0, 30)
        self.last_31_to_60 = get_range(31, 60)
        self.last_31_90 = get_range(61, 90)
        self.last_90_plus = get_range(90, 9999)
        person = SalesPerson.find_by salesperson_code: records["Salesperson Code"]
        self.salesperson_id = person.id
        self.save
    end

    def get_prices
        prices = Price.get_for_customer(self.customer_id)
        return prices
    end

    def get_balance
        sql = "SELECT SUM(a.\"Amount (LCY)\") as \"Amount\"
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Detailed Cust_ Ledg_ Entry\" as a
        where a.\"Customer No_\" = #{SqlUtils.escape(self.customer_id)}"
        records = SqlUtils.execute_sql(sql)
        return records.first["Amount"]
    end

    def get_range(start_days, end_days)
        generic_sql = "
        SELECT SUM(a.\"Amount (LCY)\") as \"Amount\"
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Detailed Cust_ Ledg_ Entry\" as a
        where a.\"Customer No_\" = #{SqlUtils.escape(self.customer_id)}
        and a.\"Expected Due Date\" < CAST(DATEADD (dd , -#{start_days}, GETDATE()) AS DATETIME)
        and a.\"Expected Due Date\" >= CAST(DATEADD (dd , -#{end_days} , GETDATE()) AS DATETIME)"
        records = SqlUtils.execute_sql(generic_sql)
        return records.first["Amount"]
    end

    def get_current
        sql = "SELECT SUM(a.\"Amount (LCY)\") as \"Amount\"
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Detailed Cust_ Ledg_ Entry\" as a
        where a.\"Customer No_\" = #{SqlUtils.escape(self.customer_id)}"
        records = SqlUtils.execute_sql(sql)
        return records.first["Amount"]
    end

end
