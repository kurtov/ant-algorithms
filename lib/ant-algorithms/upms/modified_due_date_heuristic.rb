require 'matrix'

module AntAlgorithms::UPMS
  class ModifiedDueDateHeuristic
    attr_reader :scaling_param, :processing_times, :due_dates, :weights

    def initialize(scaling_param:, processing_times:, due_dates:, weights:)
      @processing_times = processing_times
      @due_dates = due_dates
      @weights = weights
    end

    def build(mashine_number:, makespan:, remainded_jobs:)
      remainded_jobs.map do |job_number|
        weight = weights[job_number].to_f
        processing_time = processing_times[mashine_number, job_number].to_f
        due_date = due_dates[job_number].to_f

        value = weight / ([makespan + processing_time, due_date].max - makespan)

        [job_number, value]
      end
    end
  end
end
