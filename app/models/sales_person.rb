class SalesPerson < ActiveRecord::Base
    has_many :customers
    include SqlUtils

    def self.load_all
        puts "Loading all sales persons!"
        sql = "SELECT *
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Salesperson_Purchaser\""
        records = SqlUtils.execute_sql(sql)
        sales_persons = Array.new
        records.each { |person_record|
            person = SalesPerson.new
            person.salesperson_code = person_record["Code"]
            person.name = person_record["Name"]
            sales_persons << person
        }
        # save the products
        SalesPerson.delete_all
        sales_persons.each(&:save)
    end

    def update_fields
    end
end
