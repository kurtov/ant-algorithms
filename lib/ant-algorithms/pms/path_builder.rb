module AntAlgorithms::PMS
  class PathBuilder
    class Path
      attr_reader :path, :cost, :schedule

      def initialize(path:, cost:, schedule:)
        @path = path
        @cost = cost
        @schedule = schedule
      end
    end

    def initialize(processing_times:, due_dates:, mashines_count:)
      @processing_times = processing_times
      @due_dates = due_dates
      @total_processing_times = Array.new(mashines_count) { 0 }
      @schedule = Array.new(mashines_count) { [] }
      @path=[]
      @costs = Array.new(mashines_count) { 0 }
    end

    def <<(vertex)
      processing_time, mashine_number = @total_processing_times.each_with_index.min

      @schedule[mashine_number] << vertex unless @path.empty?
      @path << vertex
      @total_processing_times[mashine_number] += @processing_times[vertex]

      delay_time = [@total_processing_times[mashine_number] - @due_dates[vertex], 0].max
      @costs[mashine_number] += delay_time
    end

    def total_processing_time
      @total_processing_times.min
    end

    def build
      Path.new(path: @path, cost: cost, schedule: @schedule)
    end

    private

    def cost
      @costs.sum
    end
  end
end
