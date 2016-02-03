class Customer < ActiveRecord::Base
    belongs_to :sales_person
    has_many :prices
    include SqlUtils

    extend NavisionRecord

    def self.get_sql(code)
        return "SELECT *
                FROM #{self.table('Customer', code)}
                WHERE No_ NOT LIKE 'ZZ%'"
    end

    def self.new_active_record(record, code)
        customer = Customer.find_by customer_id: record["No_"]
        if customer.nil?
            customer = Customer.new
            customer.customer_id = record["No_"]
        end
        customer.name = record["Name"]
        customer.balance = customer.get_balance(code)
        customer.credit_limit = record["Credit Limit (LCY)"]
        customer.current = customer.get_current(code)
        customer.last_1_to_30 = customer.get_range(0, 30, code)
        customer.last_31_to_60 = customer.get_range(31, 60, code)
        customer.last_31_90 = customer.get_range(61, 90, code)
        customer.last_90_plus = customer.get_range(90, 9999, code)
        person = SalesPerson.find_by salesperson_code: record["Salesperson Code"]
        customer.sales_person = person
        return customer
    end

    def get_prices
        prices = Price.get_for_customer(self.customer_id)
        return prices
    end

    def get_balance(code)
        sql = "SELECT SUM(a.\"Amount (LCY)\") as \"Amount\"
        FROM #{Customer.table('Detailed Cust_ Ledg_ Entry', code)} as a
        where a.\"Customer No_\" = #{SqlUtils.escape(self.customer_id)}"
        records = SqlUtils.execute_sql(sql)
        return records.first["Amount"]
    end

    def get_range(start_days, end_days, code)
        generic_sql = "
        SELECT SUM(a.\"Amount (LCY)\") as \"Amount\"
        FROM #{Customer.table('Detailed Cust_ Ledg_ Entry', code)} as a
        where a.\"Customer No_\" = #{SqlUtils.escape(self.customer_id)}
        and a.\"Expected Due Date\" < CAST(DATEADD (dd , -#{start_days}, GETDATE()) AS DATETIME)
        and a.\"Expected Due Date\" >= CAST(DATEADD (dd , -#{end_days} , GETDATE()) AS DATETIME)"
        records = SqlUtils.execute_sql(generic_sql)
        return records.first["Amount"]
    end

    def get_current(code)
        sql = "SELECT SUM(a.\"Amount (LCY)\") as \"Amount\"
        FROM #{Customer.table('Detailed Cust_ Ledg_ Entry', code)} as a
        where a.\"Customer No_\" = #{SqlUtils.escape(self.customer_id)}
        and a.\"Expected Due Date\" > CAST(GETDATE() AS DATETIME)"
        records = SqlUtils.execute_sql(sql)
        return records.first["Amount"]
    end

end
