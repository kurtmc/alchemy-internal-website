class SalesController < ApplicationController
    before_filter :authenticate_admin_user!
    
    def get_column_select(columns, prefix)
        column_sql = ''
        columns.each_with_index { |col, i|
            if i == 0
                column_sql = column_sql + "SUM(#{prefix}\"#{col}\") as \"#{col}\""
            else
                column_sql = column_sql + ", SUM(#{prefix}\"#{col}\") as \"#{col}\""
            end
        }
        return column_sql
    end

    def get_sql(columns)
        column_sql = get_column_select(columns, 'sugar.')
        sql = "SELECT " + column_sql + "FROM
    NAVLIVE.dbo.\"Alchemy Agencies Ltd$Sugar CRM Staging\" AS sugar
    JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\" AS customer
    ON sugar.\"Navision Company Code\" = customer.No_
    JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Salesperson_Purchaser\" as person
    ON customer.\"Salesperson Code\" = person.Code
WHERE
    sugar.\"Date\" = #{SqlUtils.sql_date_only(Time.now - 1.day)}"
        return sql
    end

    def get_sql_individual(columns)
        sql = "SELECT person.\"Name\", #{get_column_select(columns, 'sugar.')}
        from NAVLIVE.dbo.\"Alchemy Agencies Ltd$Sugar CRM Staging\" AS sugar
        JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\" AS customer
        on sugar.\"Navision Company Code\" = customer.No_
        JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Salesperson_Purchaser\" as person
        ON customer.\"Salesperson Code\" = person.Code
        WHERE sugar.\"Date\" = #{SqlUtils.sql_date_only(Time.now - 1.day)}
        GROUP BY person.\"Name\""
        return sql
    end

    def get_sql_comparison(columns, prefix)
        sql = "
        SELECT person.\"Name\", #{get_column_select(columns, 'sugar.')}
        from NAVLIVE.dbo.\"Alchemy Agencies Ltd$Sugar CRM Staging\" AS sugar
        JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\" AS customer
        on sugar.\"Navision Company Code\" = customer.No_
        JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Salesperson_Purchaser\" as person
        ON customer.\"Salesperson Code\" = person.Code
        WHERE sugar.\"Date\" = #{SqlUtils.sql_date_only(Time.now - 1.day)}
        GROUP BY person.\"Name\"
        ORDER BY #{columns.join(",")}
        "
        # TODO ORDER BY
        return sql
    end
    
    def get_data(sql, columns)
        record = SqlUtils.execute_sql(sql).first
        data = Array.new
        columns.each { |col|
            data << record[col]
        }
        return data
    end

    def get_data_multiple(sql, columns, name_column)
        records = SqlUtils.execute_sql(sql)
        data = Array.new
        count = 0
        records.each { |record|
            dataset = Array.new
            columns.each { |col|
                dataset << record[col]
            }
            data << ChartData.new(record[name_column], dataset, "hsla(#{count},100%,50%,0.8)")
            count += 25 + rand(0...10)
        }
        return data
    end


    def index
        sales_columns = ['5LYSales', '4LYSales', '3LYSales', '2LYSales', 'LYSales', 'Sales']
        cost_columns = ['5LYCost', '4LYCost', '3LYCost', '2LYCost', 'LYCost', 'Cost']
        profit_columns = ['5LYProfit', '4LYProfit', '3LYProfit', '2LYProfit', 'LYProfit', 'Profit']
        sql = get_sql(sales_columns)
        sales = get_data(sql, sales_columns)
        sql = get_sql(cost_columns)
        cost = get_data(sql, cost_columns)
        sql = get_sql(profit_columns)
        profit = get_data(sql, profit_columns)
        colours = ['#A1862E', '#000000', '#939597', '#FFCB04']
        overall = Array.new
        overall << ChartData.new('Sales', sales, colours[0])
        overall << ChartData.new('Cost', cost, colours[1])
        overall << ChartData.new('Margin', profit, colours[2])

        labels = Array.new
        5.downto(0) { |i|
            labels << Time.now.year - i
        }
        labels = "[#{labels.map { |l| "#{l}" }.join(",")}]"
        
        @overall_html, @overall_js = ChartData.full_html_for(overall, 'overall', labels)
        
        sql = get_sql_individual(sales_columns)
        individual = get_data_multiple(sql, sales_columns, "Name")
        @individual_html, @individual_js = ChartData.full_html_for(individual, 'individual', labels)

        sql = get_sql_comparison(['Sales'], 'sugar.')
        comparison = get_data_multiple(sql, ['Sales'], "Name")
        @comparison_html, @comparison_js = ChartData.full_html_for(comparison, 'comparison', '["Current"]')
    end
end
