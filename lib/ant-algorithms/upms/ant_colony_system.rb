require 'set'
require 'byebug'

module AntAlgorithms::UPMS
  class AntColonySystem
    attr_reader(
      :processing_times,
      :due_dates,
      :weights,
      :scaling_param,
      :init_pheromone,
      :ant_count,
      :iteration_count,
      :alpha,
      :beta,
      :pheromone_decay_coef,
      :local_pheromone_decay_coef,
      :seed_select_mashine,
      :seed_exploits_select_mashine,
      :seed_select_job,
      :seed_exploits_select_job,
      :seed_local_search,
      :exploits_select_mashine_threshold,
      :exploits_select_job_threshold,
      :heuristic,
      :local_search_iteration_count,
      :local_deposited_pheromone,
      :pheromone_trail_matrix_updater,
      :pheromone_trail_matrix,
    )

    def initialize(
      processing_times:,
      due_dates:,
      weights:,
      scaling_param:,
      init_pheromone: nil,
      ant_count:,
      iteration_count: 3000,
      alpha: 1,
      beta: 5,
      pheromone_decay_coef: 0.5,
      local_pheromone_decay_coef:,
      seed_select_mashine: nil,
      seed_exploits_select_mashine: nil,
      seed_select_job: nil,
      seed_exploits_select_job: nil,
      seed_local_search: nil,
      exploits_select_mashine_threshold: nil,
      exploits_select_job_threshold: nil,
      heuristic: :earliest_due_date,
      local_search_iteration_count: 0
    )
      @processing_times = processing_times
      @due_dates= due_dates
      @weights = weights
      @scaling_param = scaling_param
      @init_pheromone = init_pheromone
      @ant_count = ant_count
      @iteration_count = iteration_count
      @alpha = alpha
      @beta = beta
      @pheromone_decay_coef = pheromone_decay_coef
      @local_pheromone_decay_coef = local_pheromone_decay_coef
      @seed_select_mashine = seed_select_mashine
      @seed_exploits_select_mashine = seed_exploits_select_mashine
      @seed_select_job = seed_select_job
      @seed_exploits_select_job = seed_exploits_select_job
      @seed_local_search = seed_local_search
      @exploits_select_mashine_threshold = exploits_select_mashine_threshold
      @exploits_select_job_threshold = exploits_select_job_threshold
      @heuristic = heuristic
      @local_search_iteration_count = local_search_iteration_count
    end

    def solve
      @local_deposited_pheromone = calculate_local_deposited_pheromone
      @init_pheromone ||= @local_deposited_pheromone
      @pheromone_trail_matrix = initialize_pheromone_trail_matrix(
        processing_times.row_count,
        processing_times.column_count,
        init_pheromone
      )
      @pheromone_trail_matrix_updater = initialize_pheromone_trail_matrix_updater(@pheromone_trail_matrix)

      min_cost = Float::MAX
      best_path = nil

      iteration_count.times.count do |iter_num|
        ant_count.times.each do |ant_num|
          path = build_ant_path

          path = local_search.search(path) if local_search_iteration_count > 0

          if path.cost < min_cost
            best_path = path
            min_cost = path.cost
          end

        end
        return best_path if min_cost == 0

        deposited_pheromone = 1.0 / min_cost
        best_path.path.each do |mashine_number, job_number|
          new_pheromone = (1 - pheromone_decay_coef) * @pheromone_trail_matrix[mashine_number, job_number] +
            pheromone_decay_coef * deposited_pheromone

          pheromone_trail_matrix_updater.update(mashine_number, job_number, new_pheromone)
        end
      end
      best_path
    end

    def build_ant_path
      jobs_count = due_dates.count
      remainded_jobs = Set.new([*0..jobs_count-1])

      path_builder = initialize_path_builder

      until remainded_jobs.empty?

        makespans = path_builder.makespans

        mashine_number = select_mashine(makespans)

        # 2d array [job_number, value]
        visabilities = visability_matrix_builder.build(
          mashine_number: mashine_number,
          makespan: makespans[mashine_number],
          remainded_jobs: remainded_jobs
        )
        # 1d array [value]
        pheromone_trails = pheromone_trail_matrix.row(mashine_number)

        ant_decision_table = visabilities.map do |job_number, visability|
          [job_number, pheromone_trails[job_number]**alpha * visability**beta]
        end

        job_number = apply_ant_decision_policy(ant_decision_table)

        mashine_number = mashine_reselector.reselect_mashine(makespans, job_number) #reselect_mashine(makespans, job_number)

        # local update
        new_local_pheromone = (1 - local_pheromone_decay_coef) * @pheromone_trail_matrix[mashine_number, job_number] +
            local_pheromone_decay_coef * local_deposited_pheromone

        pheromone_trail_matrix_updater.update(mashine_number, job_number, new_local_pheromone)


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
      # exploits
      if exploits_select_mashine_random_generator.rand <= exploits_select_mashine_threshold
        _, mashine_number = makespans.each_with_index.min
        mashine_number
      else # exploration
        visability = makespans
          .map
          .with_index { |makespan, mashine_number| [mashine_number, 1.0 / makespan] }
        AntAlgorithms::RandomValueGenerator
          .new(visability, random_generator: select_mashine_random_generator)
          .rand
      end
    end

    def apply_ant_decision_policy(ant_decision_table)
      # exploits
      if exploits_select_job_random_generator.rand <= exploits_select_job_threshold
        ant_decision_table
          .max_by{ |_, visability| visability }
          .first
      else # exploration
        AntAlgorithms::RandomValueGenerator
          .new(ant_decision_table, random_generator: select_job_random_generator)
          .rand
      end
    end

    def calculate_local_deposited_pheromone
      greedy_cost = GreedyAlgorithm
        .new(
          processing_times: processing_times,
          weights: weights,
          scaling_param: scaling_param,
          due_dates: due_dates,
          heuristic: heuristic
        )
        .solve.cost

      1.0 / (greedy_cost * ant_count)
    end

    def mashine_reselector
      @mashine_reselector ||= MashineReselector.new(
        processing_times: processing_times,
        due_dates: due_dates,
      )
    end

    def select_mashine_random_generator
      @select_mashine_random_generator ||= seed_select_mashine ? Random.new(seed_select_mashine) : Random.new
    end

    def exploits_select_mashine_random_generator
      @exploits_select_mashine_random_generator ||= seed_exploits_select_mashine ? Random.new(seed_exploits_select_mashine) : Random.new
    end

    def select_job_random_generator
      @select_job_random_generator ||= seed_select_job ? Random.new(seed_select_job) : Random.new
    end

    def exploits_select_job_random_generator
      @exploits_select_job_random_generator ||= seed_exploits_select_job ? Random.new(seed_exploits_select_job) : Random.new
    end

    def local_search_random_generator
      @local_search_random_generator ||= seed_local_search ? Random.new(seed_local_search) : Random.new
    end

    def initialize_pheromone_trail_matrix(mashines_count, jobs_count, init_pheromone)
      Matrix.build(mashines_count, jobs_count) { init_pheromone }
    end

    def initialize_pheromone_trail_matrix_updater(pheromone_trail_matrix)
      AntAlgorithms::AsymmPheromoneTrailMatrixUpdater.new(pheromone_trail_matrix)
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

    def local_search
      @local_search ||= LocalSearch.new(
        processing_times: processing_times,
        due_dates: due_dates,
        weights: weights,
        random_generator: local_search_random_generator,
        iterations_count: local_search_iteration_count
      )
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
