module AntAlgorithms::CUPMS
  class PathBuilder
    Path = Struct.new(:path, :cost, :schedule, :dropped_job_numbers)

    def initialize(mashines:, jobs:, processing_times:)
      @mashines = mashines
      @jobs = jobs
      @processing_times = processing_times

      @costs = Array.new(mashines.count) { 0 }
      @schedule = Array.new(mashines.count) { [] }
      @dropped_job_numbers = []
      @dropped_cost = 0
      @path = []
    end

    def add(mashine, job)
      processing_time = @processing_times[mashine.number, job.number]

      mashine.total_processing_time += processing_time
      mashine.capacity -= processing_time
      @schedule[mashine.number] << job.number
      @path << [mashine.number, job.number]

      delay_time = [mashine.total_processing_time - job.due_date, 0].max
      @costs[mashine.number] += job.weight * delay_time
    end

    def add_dropped_jobs(jobs)
      @dropped_job_numbers = jobs.map(&:number)
      @dropped_cost = jobs.sum(&:drop)
    end

    def build
      Path.new(@path, cost, @schedule, @dropped_job_numbers)
    end

    private

    def cost
      (@costs.sum || 0) + @dropped_cost
    end
  end
end
