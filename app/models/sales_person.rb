class SalesPerson < ActiveRecord::Base
    has_many :customers

    extend NavisionRecord

    include SqlUtils

    def self.get_sql
        return "SELECT *
        FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Salesperson_Purchaser\""
    end


    def self.new_active_record(record)
        person = SalesPerson.find_by salesperson_code: record["Code"]
        if person.nil?
            person = SalesPerson.new
            person.salesperson_code = record["Code"]
        end
        person.name = record["Name"]
        return person
    end

end
