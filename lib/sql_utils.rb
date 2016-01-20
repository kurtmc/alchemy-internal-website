require 'date'

module SqlUtils
    def self.escape(value)
        return "#{ActiveRecord::Base.connection.quote(value)}"
    end

    def self.execute_sql(sql)
        return Navision.connection.select_all(sql)
    end

    def self.sql_date(date)
        return "CAST('#{date.strftime("%Y%m%d %H:%M:00.000")}' AS DATETIME)"
    end

    def self.sql_date_only(date)
        return "CAST('#{date.strftime("%Y%m%d")}' AS DATE)"
    end
    
    def self.date_range(column, start_date, end_date)
        return "#{column} >= #{self.sql_date(start_date)} and #{column} <= #{self.sql_date(end_date)}"
    end

    def self.beginning_financial_year(date = nil)
        if date.nil?
            date = Time.now
        end
        if date >= Date.new(date.year, 4, 1)
            return Date.new(date.year, 4, 1)
        else
            return Date.new(date.year - 1, 4, 1)
        end
    end

    def self.ending_financial_year(date = nil)
        if date.nil?
            date = Time.now
        end
        if date < Date.new(date.year, 3, 31)
            return Date.new(date.year, 3, 31)
        else
            return Date.new(date.year + 1, 3, 31)
        end
    end

end
