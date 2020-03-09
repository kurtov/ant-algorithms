module AntAlgorithms::SMTTP
  class PathBuilder
    class Path
      attr_reader :path, :cost

      def initialize(path:, cost:)
        @path = path
        @cost = cost
      end

      def schedule
        @path[1..-1]
      end
    end

    attr_reader :total_processing_time

    def initialize(processing_times:, due_dates:)
      @processing_times = processing_times
      @due_dates = due_dates
      @total_processing_time = 0
      @path = []
      @cost = 0
    end

    def <<(vertex)
      @path << vertex
      @total_processing_time += @processing_times[vertex]

      delay_time = [@total_processing_time - @due_dates[vertex], 0].max
      @cost += delay_time
    end

    def build
      Path.new(path: @path, cost: @cost)
    end
  end
end
