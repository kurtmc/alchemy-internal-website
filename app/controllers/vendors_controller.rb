class VendorsController < ApplicationController
    before_filter :authenticate_user!
    def index
        @vendors = Vendor.all
    end

    def set_fields
        @vendor = Vendor.find_by vendor_id: params[:id]
        @vendor.update_fields
        stats = Array.new
        4.downto(0) { |i|
            stats << get_sales_stats(@vendor.vendor_id, Time.now - i.year)
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
        @products = Product.where vendor_id: @vendor.vendor_id

        @image_filename = get_image_path
    end

    def show
        set_fields
    end

    def get_image_path
        images = Dir.glob(Rails.root.join('public', 'images', "#{@vendor.vendor_id}.*"))
        if images.length > 0
            return File.basename(images[0])
        end
        return nil
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

    def handle_upload(uploaded_io)
        original = uploaded_io.original_filename
        new_filename = "#{@vendor.vendor_id}#{File.extname(original)}"

        # Write new file
        path = Rails.root.join('public', 'images')

        File.open(path.join(new_filename), 'wb') do |file|
            file.write(uploaded_io.read)
        end
    end

    def update
        set_fields

        unless params[:vendor_logo]['logo_file'].nil?
            uploaded_io = params[:vendor_logo]['logo_file']
            handle_upload(uploaded_io)
        end

        render 'show'
    end
end
