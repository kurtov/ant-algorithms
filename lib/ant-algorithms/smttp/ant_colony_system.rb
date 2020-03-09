require 'set'

module AntAlgorithms::SMTTP
  class AntColonySystem

    attr_reader(
      :processing_times,
      :due_dates,
      :init_pheromone,
      :ant_count,
      :iteration_count,
      :alpha,
      :beta,
      :pheromone_decay_coef,
      :vertex_count,
      :seed_next_vertex,
      :seed_exploits,
      :visability_matrix,
      :pheromone_trail_matrix,
      :exploits_threshold,
      :local_deposited_pheromone,
      :local_pheromone_decay_coef,
      :pheromone_trail_matrix_updater,
      :extended_processing_times,
      :extended_due_dates,
      :heuristic
    )

    def initialize(processing_times:, due_dates:, init_pheromone: nil, ant_count:, local_pheromone_decay_coef:, iteration_count: 3000, alpha: 1, beta: 5, pheromone_decay_coef: 0.5, seed_next_vertex: nil, seed_init_vertex: nil, seed_exploits: nil, exploits_threshold: nil, symm: true, init_vertex:nil, heuristic: :earliest_due_date)
      @processing_times = processing_times #[*processing_times, 0]
      @due_dates= due_dates #[*due_dates, 0]
      @init_pheromone = init_pheromone
      @ant_count = ant_count
      @iteration_count = iteration_count
      @alpha = alpha
      @beta = beta
      @pheromone_decay_coef = pheromone_decay_coef
      @seed_next_vertex = seed_next_vertex
      @seed_exploits = seed_exploits
      @exploits_threshold = exploits_threshold
      @local_pheromone_decay_coef = local_pheromone_decay_coef
      @extended_processing_times = [*processing_times, 0]
      @extended_due_dates = [*due_dates, 0]
      @heuristic = heuristic
    end

    def solve
      @local_deposited_pheromone = calculate_local_deposited_pheromone
      # @visability_matrix = initialize_visability_matrix #(@extended_due_dates)
      @init_pheromone ||= @local_deposited_pheromone
      @pheromone_trail_matrix = initialize_pheromone_trail_matrix(extended_due_dates.size, init_pheromone)
      @pheromone_trail_matrix_updater = initialize_pheromone_trail_matrix_updater(@pheromone_trail_matrix)

      min_cost = Float::MAX
      best_path = nil

      iteration_count.times.count do |iter_num|
        ant_count.times.each do |ant_num|
          # path, cost = build_ant_path

          # if cost < min_cost
          #   best_path = path
          #   min_cost = cost
          # end
          path = build_ant_path

          if path.cost < min_cost
            best_path = path
            min_cost = path.cost
          end

        end
        return best_path if min_cost == 0

        deposited_pheromone = 1.0 / min_cost
        best_path.path.each_cons(2) do |current_vertex, next_vertex|
          new_pheromone = (1 - pheromone_decay_coef) * @pheromone_trail_matrix[current_vertex, next_vertex] +
            pheromone_decay_coef * deposited_pheromone

          pheromone_trail_matrix_updater.update(current_vertex, next_vertex, new_pheromone)
        end
      end

      best_path
      # [best_path, min_cost]
      # [best_path[1..-1], min_cost]
    end

    private

    def build_ant_path
      @visability_matrix = initialize_visability_matrix #(@extended_due_dates)
      path_builder = initialize_path_builder
      remainded_vertex = Set.new([*0..extended_processing_times.size-1])

      # path = Path.new(processing_times: extended_processing_times, due_dates: extended_due_dates)

      next_vertex = extended_processing_times.size-1

      remainded_vertex.delete next_vertex
      path_builder << next_vertex

      current_vertex = next_vertex
      until remainded_vertex.empty?
        visabilities = visability_matrix.row(current_vertex)
        pheromone_trails = pheromone_trail_matrix.row(current_vertex)

        ant_decision_table = remainded_vertex.map do |vertex|
          [vertex, pheromone_trails[vertex]**alpha * visabilities[vertex]**beta]
        end

        next_vertex = apply_ant_decision_policy(ant_decision_table)

        # local update
        new_local_pheromone = (1 - local_pheromone_decay_coef) * @pheromone_trail_matrix[current_vertex, next_vertex] +
            local_pheromone_decay_coef * local_deposited_pheromone

        pheromone_trail_matrix_updater.update(current_vertex, next_vertex, new_local_pheromone)

        path_builder << next_vertex
        remainded_vertex.delete next_vertex

        @visability_matrix = modify_visability_matrix(path_builder.total_processing_time)

        current_vertex = next_vertex
      end

      path_builder.build
      # [path_builder.path, path_builder.cost]
      # [path_builder.path, path_builder.cost]
    end

    def apply_ant_decision_policy(ant_decision_table)
      # exploits
      if exploits_random_generator.rand <= exploits_threshold
        ant_decision_table
          .max_by{ |_, visability| visability }
          .first
      else # exploration
        AntAlgorithms::RandomValueGenerator
          .new(ant_decision_table, random_generator: next_vertex_random_generator)
          .rand
      end
    end

    def initialize_visability_matrix
      heuristic_class(@heuristic)
        .new(
          processing_times: extended_processing_times,
          due_dates: extended_due_dates
        ).build_matrix
    end

    def modify_visability_matrix(total_processing_time)
      heuristic_class(@heuristic)
        .new(
          processing_times: extended_processing_times,
          due_dates: extended_due_dates
        ).build_matrix(total_processing_time)
    end

    def heuristic_class(heuristic)
      case heuristic.to_sym
      when :earliest_due_date
        EarliestDueDateHeuristic
      when :least_slack
        LeastSlackHeuristic
      when :modified_due_date
        ModifiedDueDateHeuristic
      end
    end

    def initialize_pheromone_trail_matrix(row_count, init_pheromone)
      Matrix.build(row_count) { |row, col| row == col ? 0 : init_pheromone }
    end

    def initialize_pheromone_trail_matrix_updater(pheromone_trail_matrix)
      AntAlgorithms::AsymmPheromoneTrailMatrixUpdater.new(pheromone_trail_matrix)
    end

    def initialize_path_builder
      PathBuilder.new(
        processing_times: extended_processing_times,
        due_dates: extended_due_dates
      )
    end

    def calculate_local_deposited_pheromone
      greedy_cost = GreedyAlgorithm
        .new(
          processing_times: processing_times,
          due_dates: due_dates
        )
        .solve.cost

      1.0 / (greedy_cost * processing_times.size)
    end

    def next_vertex_random_generator
      @next_vertex_random_generator ||= seed_next_vertex ? Random.new(seed_next_vertex) : Random.new
    end

    def exploits_random_generator
      @exploits_random_generator ||= seed_exploits ? Random.new(seed_exploits) : Random.new
    end
  end
end
