module NavisionRecord

    def get_sql(code)
        raise NotImplementedError.new "get_sql"
    end

    def new_active_record(record)
        raise NotImplementedError.new "new_active_record"
    end

    def load_all
        country_code = 'NZ'
        sql = get_sql(country_code)
        records = SqlUtils.execute_sql(sql)
        records.each { |record|
            active_record = new_active_record(record)
            if active_record.has_attribute?(:country_code)
                active_record.country_code = country_code
            end
            if active_record.changed?
                active_record.save
            end
        }
    end

    def database(country_code)
        if country_code == 'AU'
            database = "NAVLIVE.dbo.\"Alchemy Agencies Pty Ltd$"
        elsif country_code == 'NZ'
            database = "NAVLIVE.dbo.\"Alchemy Agencies Ltd$"
        end
        return database
    end

    def table(name, country_code)
        return "#{self.database(country_code)}#{name}\""
    end

end
