class Agency < ActiveRecord::Base
    has_many :vendors

    extend NavisionRecord

    def self.get_sql
        return "
            SELECT
            DISTINCT item.\"Global Dimension 1 Code\" as \"Dimension\"
            FROM
            NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\" AS item
            WHERE
            item.\"Global Dimension 1 Code\" <> ''
            AND NOT item.\"Global Dimension 1 Code\" LIKE 'ZZ%'
        "
    end

    def self.new_active_record(record)
        agency = Agency.find_by agency_id: record['Dimension']
        if agency.nil?
            agency = Agency.new
            agency.agency_id = record['Dimension']
        end
        agency.name = record["Dimension"]
        return agency
    end
end
