class AgenciesController < ApplicationController

    def index
        @agencies = Agency.all.order :agency_id
    end

    def show
        @agency = Agency.find(params[:id])
        vendors = @agency.vendors
        @products = Array.new
        vendors.each { |v|
            v.products.each { |p|
                @products << p
            }
        }
        @products = @products.sort_by {|p| p.product_id}

        set_fields
    end

    def get_sales_stats(agency_id, date = nil)
        column = 't."Posting Date"'
        start_date = SqlUtils.beginning_financial_year(date)
        end_date = SqlUtils.ending_financial_year(date)
        sql = "
        SELECT
            SUM(s.Quantity) AS \"Volume\",
            SUM(s.\"Sales Amount (Actual)\") AS \"Sales\",
            SUM(s.\"Cost Amount (Actual)\") AS \"Cost\"
        FROM (
SELECT
	t.No_,
    t.\"Item No_\",
    t.\"Salesperson Code\",
    t.\"Invoiced Quantity\",
    t.\"Global Dimension 1 Code\",
    t.Quantity,
    t.\"Sales Amount (Actual)\",
    t.\"Cost Amount (Actual)\",
    t.\"Posting Date\"
FROM
    (
        SELECT
            \"Alchemy Agencies Ltd$Customer\" . No_,
            \"Alchemy Agencies Ltd$Customer\" . \"Salesperson Code\",
            \"Alchemy Agencies Ltd$Item\" . Description,
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Unit of Measure Code\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Entry Type\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"External Document No_\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Invoiced Quantity\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Item Category Code\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Product Group Code\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Item No_\",
            \"Alchemy Agencies Ltd$Item\" . \"Global Dimension 1 Code\",
            \"Alchemy Agencies Ltd$Item\" . \"Global Dimension 2 Code\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Location Code\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Document Date\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Posting Date\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . Quantity,
            \"Alchemy Agencies Ltd$Value Entry\" . \"Item Ledger Entry Quantity\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Source No_\",
            \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Source Type\",
            \"Alchemy Agencies Ltd$Value Entry\" . \"Sales Amount (Actual)\",
            \"Alchemy Agencies Ltd$Value Entry\" . \"Sales Amount (Expected)\",
            \"Alchemy Agencies Ltd$Value Entry\" . \"Cost Amount (Actual)\",
            \"Alchemy Agencies Ltd$Value Entry\" . \"Cost Amount (Expected)\",
            \"Alchemy Agencies Ltd$Value Entry\" . \"Cost Posted to G_L\",
            NAVLIVE.dbo.\"Alchemy Agencies Ltd$Default Dimension\" . [Dimension VALUE Code] AS \"Product Dimension\"
        FROM
            NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item Ledger Entry\" \"Alchemy Agencies Ltd$Item Ledger Entry\" JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Customer\" \"Alchemy Agencies Ltd$Customer\"
                ON \"Alchemy Agencies Ltd$Customer\" . No_ = \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Source No_\" JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Item\" \"Alchemy Agencies Ltd$Item\"
                ON \"Alchemy Agencies Ltd$Item\" . No_ = \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Item No_\" JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Value Entry\" \"Alchemy Agencies Ltd$Value Entry\"
                ON \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Entry No_\" = \"Alchemy Agencies Ltd$Value Entry\" . \"Item Ledger Entry No_\" LEFT JOIN NAVLIVE.dbo.\"Alchemy Agencies Ltd$Default Dimension\"
                ON \"Alchemy Agencies Ltd$Default Dimension\" . \"Table ID\" = 27
            AND \"Alchemy Agencies Ltd$Default Dimension\" . \"No_\" = \"Alchemy Agencies Ltd$Item\" . No_
            AND \"Alchemy Agencies Ltd$Default Dimension\" . \"Dimension Code\" = 'PRODUCT GROUP'
        WHERE
            \"Alchemy Agencies Ltd$Item\" . No_ = \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Item No_\"
            AND \"Alchemy Agencies Ltd$Customer\" . No_ = \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Source No_\"
            AND \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Entry No_\" = \"Alchemy Agencies Ltd$Value Entry\" . \"Item Ledger Entry No_\"
            AND(
                (
                    \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Source Type\" = 1
                )
                AND(
                    \"Alchemy Agencies Ltd$Item Ledger Entry\" . \"Entry Type\" = 1
                )
            )
    ) t
    WHERE
        t.\"Global Dimension 1 Code\" = #{SqlUtils.escape(@agency.agency_id)}
        and #{SqlUtils.date_range(column, start_date, end_date)}
        ) s"
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
        result["Margin"] = result["Sales"] + result["Cost"]
        result["Cost"] = -1 * result["Cost"]
        result["Volume"] = -1 * result["Volume"]
        return result
    end

    def set_fields
        stats = Array.new
        4.downto(0) { |i|
            stats << get_sales_stats(@agency.agency_id, Time.now - i.year)
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
        data_sets << ChartData.new("Volume", data, "hsla(234, 100%, 50%, 0.8)")
        data_sets[0].colour = '#A1862E'
        data_sets[1].colour = '#000000'
        data_sets[2].colour = '#939597'
        data_sets[3].colour = '#FFCB04'

        labels = Array.new
        4.downto(0) { |i|
            labels << Time.now.year - i
        }
        labels = "[#{labels.map { |l| "#{l}" }.join(",")}]"

        @sales_html, @sales_js = ChartData.full_html_for(data_sets, 'sales', labels)
        @image_filename = get_image_path
    end

    def get_image_path
        images = Dir.glob(Rails.root.join('public', 'images', "#{@agency.agency_id}.*"))
        if images.length > 0
            return File.basename(images[0])
        end
        return nil
    end

    def handle_upload(uploaded_io)
        original = uploaded_io.original_filename
        new_filename = "#{@agency.agency_id}#{File.extname(original)}"

        # Write new file
        path = Rails.root.join('public', 'images')

        File.open(path.join(new_filename), 'wb') do |file|
            file.write(uploaded_io.read)
        end
    end

    def update
        set_fields

        unless params[:agency_logo]['logo_file'].nil?
            uploaded_io = params[:agency_logo]['logo_file']
            handle_upload(uploaded_io)
        end

        render 'show'
    end

end

