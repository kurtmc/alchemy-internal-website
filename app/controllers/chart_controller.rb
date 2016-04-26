class ChartController < ApplicationController

    include NavisionRecord

    # This query is from some table special Excel thing that Alchemy uses
    def main_query
        return "SELECT
    customer . No_,
    customer . \"Salesperson Code\",
    item . Description,
    ledger . \"Unit of Measure Code\",
    ledger . \"Entry Type\",
    ledger . \"External Document No_\",
    ledger . \"Invoiced Quantity\",
    ledger . \"Item Category Code\",
    ledger . \"Product Group Code\",
    ledger . \"Item No_\",
    item . \"Vendor No_\",
    item . \"Global Dimension 1 Code\",
    item . \"Global Dimension 2 Code\",
    ledger . \"Location Code\",
    ledger . \"Document Date\",
    ledger . \"Posting Date\",
    ledger . Quantity,
    value_entry . \"Item Ledger Entry Quantity\",
    ledger . \"Source No_\",
    ledger . \"Source Type\",
    value_entry . \"Sales Amount (Actual)\",
    value_entry . \"Sales Amount (Expected)\",
    value_entry . \"Cost Amount (Actual)\",
    value_entry . \"Cost Amount (Expected)\",
    value_entry . \"Cost Posted to G_L\",
    default_dim . [Dimension VALUE Code] AS \"Product Dimension\"
FROM
    #{table('Item Ledger Entry', 'NZ')} AS ledger
    JOIN #{table('Customer', 'NZ')} AS customer
        ON customer . No_ = ledger . \"Source No_\"
    JOIN #{table('Item', 'NZ')} as item
        ON item . No_ = ledger . \"Item No_\"
    JOIN #{table('Value Entry', 'NZ')} AS value_entry
        ON ledger . \"Entry No_\" = value_entry . \"Item Ledger Entry No_\"
    LEFT JOIN #{table('Default Dimension', 'NZ')} as default_dim
        ON default_dim . \"Table ID\" = 27
    AND default_dim . \"No_\" = item . No_
    AND default_dim . \"Dimension Code\" = 'PRODUCT GROUP'
WHERE
    item . No_ = ledger . \"Item No_\"
    AND customer . No_ = ledger . \"Source No_\"
    AND ledger . \"Entry No_\" = value_entry . \"Item Ledger Entry No_\"
    AND(
        (
            ledger . \"Source Type\" = 1
        )
        AND(
            ledger . \"Entry Type\" = 1
        )
    )"
    end

    def where_clause
        raise NotImplementedError.new "where_clause"
    end

    def get_stats(date = nil)
        column = 't."Posting Date"'
        start_date = SqlUtils.beginning_financial_year(date)
        end_date = SqlUtils.ending_financial_year(date)
        sql = "
        SELECT
            SUM(s.Quantity) AS \"Volume\",
            SUM(s.\"Sales Amount (Actual)\") AS \"Sales\",
            SUM(s.\"Cost Amount (Actual)\") AS \"Cost\" 
		FROM (
		SELECT *
        FROM (
			#{main_query}
		) t
    	WHERE
        #{where_clause}
        and #{SqlUtils.date_range(column, start_date, end_date)}
		) s"
        records = SqlUtils.execute_sql(sql)
        result = Hash.new
        result["Volume"] = 0
        result["Sales"] = 0
        result["Cost"] = 0
        records.each { |record|
            result["Volume"] += record["Volume"].to_f
            result["Sales"] += record["Sales"].to_f
            result["Cost"] += record["Cost"].to_f
        }
        result["Margin"] = result["Sales"] + result["Cost"]
        result["Cost"] = -1 * result["Cost"]
        result["Volume"] = -1 * result["Volume"]
        return result
    end

    def get_charts
        stats = Array.new
        4.downto(0) { |i|
            stats << get_stats(Time.now - i.year)
        }

        data_sets = Array.new
        ["Sales", "Cost", "Margin"].each { |stat_name|
            data = Array.new
            stats.each { |stat|
                data << stat[stat_name]
            }
            data_sets << ChartData.new(stat_name, data)
        }

        volumes = Array.new
        data = Array.new
        stats.each { |stat|
            data << stat["Volume"]
        }
        data_sets << ChartData.new("Volume", data, nil)

        # Alchemy colour palette
        data_sets[0].colour = '#A1862E'
        data_sets[1].colour = '#000000'
        data_sets[2].colour = '#939597'
        data_sets[3].colour = '#FFCB04'

        labels = Array.new
        4.downto(0) { |i|
            labels << Time.now.year - i
        }
        labels = "[#{labels.map { |l| "#{l}" }.join(",")}]"

        return ChartData.full_html_for(data_sets, 'sales', labels)
    end
end
