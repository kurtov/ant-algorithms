require 'set'

module AntAlgorithms::UPMS
  class GreedyAlgorithm
    attr_reader(
      :processing_times,
      :due_dates,
      :weights,
      :scaling_param,
      :heuristic
    )

    def initialize(processing_times:, due_dates:, weights:, scaling_param:, heuristic: :apparent_tardiness_cost_heuristic)
      @processing_times = processing_times
      @due_dates = due_dates
      @weights = weights
      @scaling_param = scaling_param
      @heuristic = heuristic
    end

    def solve
      build_ant_path
    end

    private

    def build_ant_path
      jobs_count = due_dates.count
      remainded_jobs = Set.new([*0..jobs_count-1])

      path_builder = initialize_path_builder

      until remainded_jobs.empty?
        makespans = path_builder.makespans

        mashine_number = select_mashine(makespans)

        ant_decision_table = visability_matrix_builder.build(
          mashine_number: mashine_number,
          makespan: makespans[mashine_number],
          remainded_jobs: remainded_jobs
        )
        job_number = apply_ant_decision_policy(ant_decision_table)

        mashine_number = mashine_reselector.reselect_mashine(makespans, job_number) #reselect_mashine(makespans, job_number)

        remainded_jobs.delete job_number
        path_builder.add(mashine_number, job_number)
      end

      path_builder.build
    end

    def initialize_path_builder
      PathBuilder.new(
        processing_times: processing_times,
        due_dates: due_dates,
        weights: weights
      )
    end

    def select_mashine(makespans)
      _, mashine_number = makespans.each_with_index.min
      mashine_number
    end

    def visability_matrix_builder
      @visability_matrix_builder ||= heuristic_class(@heuristic)
        .new(
          scaling_param: scaling_param,
          processing_times: processing_times,
          due_dates: due_dates,
          weights: weights
        )
    end

    def mashine_reselector
      @mashine_reselector ||= MashineReselector.new(
        processing_times: processing_times,
        due_dates: due_dates,
      )
    end

    def apply_ant_decision_policy(ant_decision_table)
      ant_decision_table
        .max_by{ |_, visability| visability }
        .first
    end

    def heuristic_class(heuristic)
      case heuristic.to_sym
      when :apparent_tardiness_cost_heuristic
        ApparentTardinessCostHeuristic
      when :apparent_urgency_heuristic
        ApparentUrgencyHeuristic
      when :modified_due_date
        ModifiedDueDateHeuristic
      end
    end
  end
end
