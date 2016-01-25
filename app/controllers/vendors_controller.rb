class VendorsController < ApplicationController
    before_filter :authenticate_user!
    def index
        @vendors = Vendor.all
    end

    def show
        @vendor = Vendor.find_by vendor_id: params[:id]
        @vendor.update_fields
        stats = Array.new
        4.downto(0) { |i|
            stats << get_sales_stats(@vendor.vendor_id, Time.now - i.year)
        }
        @data_sets = Array.new
        ["Sales", "Cost", "Margin"].each { |stat_name|
            data = Array.new
            stats.each { |stat|
                data << stat[stat_name]
            }
            @data_sets << ChartData.new(stat_name, data)
        }
        colourize_data_sets!(@data_sets)
        @labels = Array.new
        4.downto(0) { |i|
            @labels << Time.now.year - i
        }
        @labels = "[#{@labels.map { |l| "#{l}" }.join(",")}]"
    end

    def get_sales_stats(vendor_id, date = nil)
		column = 'sales."Shipment Date"'
		start_date = SqlUtils.beginning_financial_year(date)
		end_date = SqlUtils.ending_financial_year(date)
        sql = "
        SELECT

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

        sales.No_ IN (
            SELECT No_
            FROM NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\" as item
            WHERE item.\"Vendor No_\" = #{SqlUtils.escape(vendor_id)}
        )
		and #{SqlUtils.date_range(column, start_date, end_date)}

        ) stats

        GROUP BY

        stats.No_
        "
		records = SqlUtils.execute_sql(sql)
        result = Hash.new
        result["Volume"] = 0
        result["Sales"] = 0
        result["Cost"] = 0
        records.each { |record|
            result["Volume"] += record["Volume"]
            result["Sales"] += record["Sales"]
            result["Cost"] += record["Cost"]
        }
        result["Margin"] = result["Sales"] - result["Cost"]
        return result
    end

    def colourize_data_sets!(data_sets)
        len = data_sets.length
        num = 0;
        
        for i in 0...len
            data_sets[i].colour.replace "hsla(#{num}, 100%, 50%, 0.8)"
            num += 255/len
        end
    end
end
