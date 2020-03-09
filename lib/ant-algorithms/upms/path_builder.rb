module AntAlgorithms::UPMS
  class PathBuilder
    class Path
      attr_reader :path, :cost, :schedule

      def initialize(path:, cost:, schedule:)
        @path = path
        @cost = cost
        @schedule = schedule
      end
    end

    def initialize(processing_times:, due_dates:, weights:)
      mashines_count = processing_times.row_count
      @processing_times = processing_times
      @due_dates = due_dates
      @total_processing_times = Array.new(mashines_count) { 0 }
      @schedule = Array.new(mashines_count) { [] }
      @path=[]
      @costs = Array.new(mashines_count) { 0 }
      @weights = weights
    end

    def add(mashine_number, job)
      @schedule[mashine_number] << job
      @path << [mashine_number, job]
      @total_processing_times[mashine_number] += @processing_times[mashine_number, job]

      delay_time = [@total_processing_times[mashine_number] - @due_dates[job], 0].max
      @costs[mashine_number] += @weights[job] * delay_time
    end


    def build
      Path.new(path: @path, cost: cost, schedule: @schedule)
    end

    def makespans
      @total_processing_times
    end

    private

    def cost
      @costs.sum
    end
  end
end
