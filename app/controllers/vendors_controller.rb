class VendorsController < ChartController
    def index
        @vendors = Vendor.all.order :vendor_id
    end

    def set_fields
        @vendor = Vendor.find(params[:id])
        stats = Array.new
        4.downto(0) { |i|
            stats << get_sales_stats(@vendor.vendor_id, Time.now - i.year, params[:global] == 'true')
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

    def get_sales_stats(vendor_id, date = nil, global = false)
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
        t.\"Vendor No_\" = #{SqlUtils.escape(@vendor.vendor_id)}
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
