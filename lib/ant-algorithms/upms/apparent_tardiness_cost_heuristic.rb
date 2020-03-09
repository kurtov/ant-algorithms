module AntAlgorithms::UPMS
  class ApparentTardinessCostHeuristic
    attr_reader :scaling_param, :processing_times, :due_dates, :weights

    def initialize(scaling_param:, processing_times:, due_dates:, weights:)
      @scaling_param = scaling_param
      @processing_times = processing_times
      @due_dates = due_dates
      @weights = weights
    end

    def build(mashine_number:, makespan:, remainded_jobs:)
      remainded_jobs.map do |job_number|
        weight = weights[job_number].to_f
        processing_time = processing_times[mashine_number, job_number].to_f
        average_pricessing_time = average_pricessing_times[mashine_number].to_f
        due_date = due_dates[job_number].to_f

        value = weight / processing_time *
          Math.exp(
            -(weight*[due_date - processing_time - makespan, 0].max) /
            (scaling_param*average_pricessing_time)
          )

        [job_number, value]
      end
    end

    def average_pricessing_times
      @average_pricessing_times ||= begin
        jobs_count = processing_times.column_count.to_f
        processing_times.row_vectors.map do |processing_times_for_mashine|
          processing_times_for_mashine.to_a.sum / jobs_count
        end
      end
    end
  end
end
