module AntAlgorithms::UPMS
  class MashineReselector
    attr_reader :processing_times, :due_dates

    def initialize(processing_times:, due_dates:)
      @processing_times = processing_times
      @due_dates = due_dates
    end

    def reselect_mashine(makespans, job_number)
      mashine_count = makespans.count
      job_processing_times = processing_times.column(job_number).to_a
      due_date = due_dates[job_number]

      tardinesses = mashine_count.times.map do |mashine_number|
        makespans[mashine_number] + job_processing_times[mashine_number] - due_date
      end

      _, mashine_number = job_processing_times.zip(tardinesses)
        .each_with_index
        .select { |(_, tardiness), _| tardiness <= 0 }
        .min_by{ |(processing_time, _), _| processing_time  }

      if mashine_number.nil?
        _, mashine_number = tardinesses.each_with_index.min
      end

      mashine_number
    end
  end
end
