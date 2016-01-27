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

end
