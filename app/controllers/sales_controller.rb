class SalesController < ApplicationController
    def get_sql(columns)
        column_sql = ''
        columns.each_with_index { |col, i|
            if i == 0
                column_sql = column_sql + "SUM(sugar.\"#{col}\") as \"#{col}\""
            else
                column_sql = column_sql + ", SUM(sugar.\"#{col}\") as \"#{col}\""
            end
        }
        sql = "SELECT " + column_sql + "FROM
    NAVLIVE.dbo.\"Alchemy Agencies Ltd$Sugar CRM Staging\" AS sugar
    JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\" AS customer
    ON sugar.\"Navision Company Code\" = customer.No_
    JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Salesperson_Purchaser\" as person
    ON customer.\"Salesperson Code\" = person.Code
WHERE
    sugar.\"Date\" = CAST(
        '2016-01-20' AS DATETIME
    )"
    end
    
    def get_data(sql, columns)
        record = SqlUtils.execute_sql(sql).first
        data = Array.new
        columns.each { |col|
            data << record[col]
        }
        return data
    end
        Customer = Struct.new(:name, :address) do
            def greeting
                "Hello #{name}!"
            end
        end
        Chart = Struct.new(:name, :data, :colour)

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
        @sales = Chart.new('Sales', "[#{sales.join(",")}]", 'rgba(0, 255, 0, 0.2)')
        @cost = Chart.new('Cost', "[#{cost.join(",")}]", 'rgba(255, 0, 0, 0.2)')
        @profit = Chart.new('Profit', "[#{profit.join(",")}]", 'rgba(0, 0, 255, 0.2)')
        @data_sets = [@sales, @cost, @profit]
    end
end
