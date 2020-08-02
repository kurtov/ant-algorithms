require 'set'

module AntAlgorithms::CUPMS
  class GreedyAlgorithm
    Mashine = Struct.new(:number, :total_processing_time, :capacity)
    Job = Struct.new(:number, :due_date, :weight, :drop)

    attr_reader(
      :processing_times,
      :due_dates,
      :weights,
      :drops,
      :shifts,
      :scaling_param,
      :heuristic,
      :jobs,
      :mashines
    )

    def initialize(processing_times:, due_dates:, weights:, drops:, shifts:, scaling_param:, heuristic: :apparent_tardiness_cost_heuristic)
      @processing_times = processing_times
      @due_dates = due_dates
      @weights = weights
      @drops = drops
      @shifts = shifts
      @scaling_param = scaling_param
      @heuristic = heuristic

      @mashines = shifts.map.with_index do |shift, index|
        Mashine.new(index, shift[0], shift[1] - shift[0])
      end

      @jobs = due_dates.zip(weights, drops).map.with_index do |(due_date, weight, drop), index|
        Job.new(index, due_date, weight, drop)
      end
    end

    def solve
      build_ant_path
    end

    private

    def build_ant_path
      remainded_jobs = Set.new(jobs)
      available_mashines = Set.new(mashines)
      available_mashines.compare_by_identity

      path_builder = initialize_path_builder

      until remainded_jobs.empty?
        mashine=nil
        available_jobs_for_selected_mashine=[]
        while available_jobs_for_selected_mashine.empty?
          break if available_mashines.empty?
          mashine = select_mashine(available_mashines)

          available_jobs_for_selected_mashine = remainded_jobs.select do |job|
            processing_times[mashine.number, job.number] <= mashine.capacity
          end

          available_mashines.delete(mashine) if available_jobs_for_selected_mashine.empty?
        end
        break if available_jobs_for_selected_mashine.empty?

        job = select_job(mashine, available_jobs_for_selected_mashine)

        available_mashines_for_selected_job = available_mashines.select do |mashine|
          processing_times[mashine.number, job.number] <= mashine.capacity
        end

        mashine = reselect_mashine(
          job: job,
          mashines: available_mashines_for_selected_job
        )

        remainded_jobs.delete(job)

        path_builder.add(mashine, job)
      end

      path_builder.add_dropped_jobs(remainded_jobs)
      path_builder.build
    end

    def initialize_path_builder
      PathBuilder.new(
        mashines: mashines,
        jobs: jobs,
        processing_times: processing_times
      )
    end

    def select_mashine(available_mashines)
      available_mashines.min_by(&:total_processing_time)
    end

    def select_job(mashine, available_jobs)
      ant_decision_table = visability_matrix_builder.build(
        mashine_number: mashine.number,
        makespan: mashine.total_processing_time,
        remainded_jobs: available_jobs.map(&:number)
      )

      job_number = apply_ant_decision_policy(ant_decision_table)
      jobs[job_number]
    end

    def reselect_mashine(job:, mashines:)
      mashine_reselector.reselect_mashine(job: job, mashines: mashines)
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
      @mashine_reselector ||= MashineReselector.new(processing_times: processing_times)
    end

    def apply_ant_decision_policy(ant_decision_table)
      ant_decision_table
        .max_by{ |_, visability| visability }
        .first
    end

    def heuristic_class(heuristic)
      case heuristic.to_sym
      when :apparent_tardiness_cost_heuristic
        AntAlgorithms::UPMS::ApparentTardinessCostHeuristic
      when :apparent_urgency_heuristic
        AntAlgorithms::UPMS::ApparentUrgencyHeuristic
      when :modified_due_date
        AntAlgorithms::UPMS::ModifiedDueDateHeuristic
      end
    end
  end
end
