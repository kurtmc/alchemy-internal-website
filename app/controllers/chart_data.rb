class ChartData
    def initialize(name, data, colour)
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
end
