module AntAlgorithms::CUPMS
  class MashineReselector
    attr_reader :processing_times

    def initialize(processing_times:)
      @processing_times = processing_times
    end

    def reselect_mashine(job:, mashines:)
      tardinesses = mashines.map do |mashine|
        processing_time = processing_times[mashine.number, job.number]

        [mashine, processing_time, mashine.total_processing_time + processing_time - job.due_date]
      end

      mashine = tardinesses
        .select { |_, _, tardiness| tardiness <= 0 }
        .min_by { |_, processing_time, _| processing_time }
        &.first

      return mashine if mashine

      tardinesses
        .min_by { |_, _, tardiness| tardiness }
        .first
    end
  end
end
