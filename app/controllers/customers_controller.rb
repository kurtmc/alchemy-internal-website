class CustomersController < ApplicationController
    before_filter :authenticate_user!
    def index
        @customers = Customer.all.order :customer_id
    end

    def show
        @customer = Customer.find(params[:id])
		ytd = get_sales_stats(params[:id])
		py = get_sales_stats(params[:id], Time.now - 1.year)
        sales = Hash.new
        sales['Product ID'] = Hash.new
        data_sets = Hash.new
        data_sets['ytd'] = ytd
        data_sets['py'] = py
        data_sets.each { |key, value|
            value.each { |stat|
                product_id = stat["Product ID"]
                if sales['Product ID'][product_id].nil?
                    sales['Product ID'][product_id] = Hash.new
                end
                sales['Product ID'][product_id][key] = Hash.new
                sales['Product ID'][product_id][key]['Volume'] = stat['Volume']
                sales['Product ID'][product_id][key]['Sales'] = stat['Sales']
                sales['Product ID'][product_id][key]['Cost'] = stat['Cost']
                sales['Product ID'][product_id][key]['Margin'] = stat['Sales'] - stat['Cost']
            }
        }
        @sales_stats = sales
    end

    def get_sales_stats(id, date = nil)
        customer_id = Customer.find(id).customer_id
		column = 'sales."Shipment Date"'
		start_date = SqlUtils.beginning_financial_year(date)
		end_date = SqlUtils.ending_financial_year(date)
		sql ="SELECT
    stats.No_ AS \"Product ID\",
    SUM(stats.Volume) AS \"Volume\",
    SUM(stats.Sales) AS \"Sales\",
    SUM(stats.Cost) AS \"Cost\"
FROM
    (
        SELECT
            sales.No_,
           	sales.Quantity as \"Volume\",
            sales.Quantity * sales.\"Unit Price\" AS \"Sales\",
            sales.Quantity * sales.\"Unit Cost (LCY)\" AS \"Cost\"
        FROM
            NAVLIVE.dbo.\"Alchemy Agencies Ltd$Sales Line Archive\" AS sales
        WHERE
            sales.\"Sell-to Customer No_\" = #{SqlUtils.escape(customer_id)}
			and #{SqlUtils.date_range(column, start_date, end_date)}
    ) stats
GROUP BY
    stats.No_"
		records = SqlUtils.execute_sql(sql)
		records.each { |record|
			if record["Sales"] == 0 || record["Cost"] == 0
                record["Sales"] = 0
                record["Cost"] = 0
            end
		}
        return records
    end
end
