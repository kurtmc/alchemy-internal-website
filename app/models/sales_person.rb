class SalesPerson < ActiveRecord::Base
    has_many :customers
    include SqlUtils

    def self.load_all
        sql = "SELECT *
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Salesperson_Purchaser\""
        records = SqlUtils.execute_sql(sql)
        sales_persons = Array.new
        records.each { |person_record|
            person = SalesPerson.find_by salesperson_code: person_record["Code"]
            if person.nil?
                person = SalesPerson.new
                person.salesperson_code = person_record["Code"]
            end
            person.name = person_record["Name"]
            if person.changed?
                person.save
            end
        }
    end

    def update_fields
    end
end
