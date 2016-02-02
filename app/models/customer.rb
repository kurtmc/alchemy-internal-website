class Customer < ActiveRecord::Base
    belongs_to :sales_person
    has_many :prices
    include SqlUtils

    extend NavisionRecord

    def self.get_sql
        return "SELECT *
                FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\"
                WHERE No_ NOT LIKE 'ZZ%'"
    end

    def self.new_active_record(record)
        customer = Customer.find_by customer_id: record["No_"]
        if customer.nil?
            customer = Customer.new
            customer.customer_id = record["No_"]
        end
        customer.name = record["Name"]
        customer.balance = get_balance
        customer.credit_limit = record["Credit Limit (LCY)"]
        customer.current = get_current
        customer.last_1_to_30 = get_range(0, 30)
        customer.last_31_to_60 = get_range(31, 60)
        customer.last_31_90 = get_range(61, 90)
        customer.last_90_plus = get_range(90, 9999)
        person = SalesPerson.find_by salesperson_code: record["Salesperson Code"]
        customer.salesperson_id = person.id
        return customer
    end

    def self.load_all
        SalesPerson.all.each { |person|
            sql = "SELECT *
          FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\"
          WHERE \"Salesperson Code\" = #{SqlUtils.escape(person.salesperson_code)}
          AND No_ NOT LIKE 'ZZ%'"
          records = SqlUtils.execute_sql(sql)
          records.each { |customer_record|
          }
        }
    end

    def update_fields
        sql = "SELECT *
      FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\"
      WHERE No_ = #{SqlUtils.escape(self.customer_id)}"
        records = SqlUtils.execute_sql(sql).first
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
        where a.\"Customer No_\" = #{SqlUtils.escape(self.customer_id)}
        and a.\"Expected Due Date\" > CAST(GETDATE() AS DATETIME)"
        records = SqlUtils.execute_sql(sql)
        return records.first["Amount"]
    end

end
