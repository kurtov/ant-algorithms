module AntAlgorithms::UPMS
  class ApparentUrgencyHeuristic
    attr_reader :scaling_param, :processing_times, :due_dates, :weights

    def initialize(scaling_param:, processing_times:, due_dates:, weights:)
      @scaling_param = scaling_param
      @processing_times = processing_times
      @due_dates = due_dates
      @weights = weights
    end

    def build(mashine_number:, makespan:, remainded_jobs:)
      average_pricessing_time = average_pricessing_time(mashine_number, remainded_jobs)

      remainded_jobs.map do |job_number|
        weight = weights[job_number].to_f
        processing_time = processing_times[mashine_number, job_number].to_f
        due_date = due_dates[job_number].to_f

        value = weight / processing_time *
          Math.exp(
            -([due_date - processing_time - makespan, 0].max) /
            (scaling_param*average_pricessing_time)
          )

        [job_number, value]
      end
    end

    # Average of processing times of all unscheduled jobs
    def average_pricessing_time(mashine_number, remainded_jobs)
      jobs_count = remainded_jobs.count.to_f
      processing_times_for_mashine = processing_times.row(mashine_number)

      remainded_jobs
        .map { |job_number| processing_times_for_mashine[job_number] }
        .sum / jobs_count
    end
  end
end
