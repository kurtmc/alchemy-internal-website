module SqlUtils
    def self.escape(value)
        return "#{ActiveRecord::Base.connection.quote(value)}"
    end

    def self.execute_sql(sql)
        return Navision.connection.select_all(sql)
    end

    def self.sql_date(year, month, day)
        date = Date.new(year, month, day)
        return "CAST('#{date.strftime("%Y%m%d %H:%M:00.000")}' AS DATETIME)"
    end

end
