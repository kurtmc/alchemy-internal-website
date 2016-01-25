class ChartData
    def initialize(name, data, colour = '#ffffff')
        @name = name
        @data = data
        @colour = colour
    end

    def name=(name)
        @name = name
    end

    def name
        return @name
    end

    def data=(data)
        @data = data
    end


    def data
        if @data.kind_of?(Array)
            return "[#{@data.map { |d| "#{d}" }.join(",")}]"
        end
        return "[#{@data}]"
    end

    def data_js
        return "{
    label: \"#{name}\",
    fillColor: \"#{@colour}\",
    strokeColor: \"#{@colour}\",
    pointColor: \"#{@colour}\",
    pointStrokeColor: \"#fff\",
    pointHighlightFill: \"#fff\",
    pointHighlightStroke: \"#{@colour}\",
    data: #{self.data}
}"
    end

    def colour=(colour)
        return @colour
    end

    def colour
        return @colour
    end

    def self.data_sets_js(data_sets)
        result = '['
        data_sets.each_with_index do |data, i|
            unless i.zero?
                result += ','
            end
            result += data.data_js
        end
        result += ']'
    end

    def self.legend_template_js(chart_name)
        return "\"<ul class=\\\"<%=name.toLowerCase()%>-legend list-group\\\" style=\\\"list-style-type: none;\\\"><% for (var i=0; i<datasets.length; i++){%><li class=\\\"legend-item list-group-item\\\" onclick=\\\"updateDataset($(this), window.#{chart_name}, '<%=datasets[i].label%>')\\\"><span style=\\\"background-color:<%=datasets[i].strokeColor%>\\\">&nbsp;&nbsp;&nbsp;</span>&nbsp;&nbsp;&nbsp;<%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>\""
    end

    def self.tool_tip_template_js
        return "\"<%= datasetLabel %> - <%= '$' + value.formatMoney(2) %>\""
    end

    def self.full_html_for(data_sets, id, labels)
        html_tags =
            "<canvas id=\"#{id}\" width=\"800\" height=\"400\"></canvas>
            <div id=\"#{id}-legend\" class=\"chart-legend\"></div>"

        js = "
var options_#{id} = {
  legendTemplate : #{self.legend_template_js("#{id}_chart")},
  multiTooltipTemplate: #{self.tool_tip_template_js}
}
var data_#{id} = {
  labels: #{labels},
  datasets: #{self.data_sets_js(data_sets)}
  };

var ctx = document.getElementById(\"#{id}\").getContext(\"2d\");
window.#{id}_chart = new Chart(ctx).Bar(data_#{id}, options_#{id});
document.getElementById('#{id}-legend').innerHTML = window.#{id}_chart.generateLegend();
window.#{id}_chart.store = new Array();
        "

        return html_tags, js
    end
end
