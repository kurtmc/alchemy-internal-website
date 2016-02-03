module NavisionRecord

    def get_sql
        raise NotImplementedError.new "get_template"
    end

    def new_active_record(record)
        raise NotImplementedError.new "get_template"
    end

    def load_all
        sql = get_sql
        records = SqlUtils.execute_sql(sql)
        records.each { |record|
            active_record = new_active_record(record)
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
