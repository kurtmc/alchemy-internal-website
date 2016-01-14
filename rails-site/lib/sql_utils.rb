module SqlUtils
    def self.escape(value)
        return "#{ActiveRecord::Base.connection.quote(value)}"
    end

    def self.execute_sql(sql)
        return Navision.connection.select_all(sql)
    end
end
