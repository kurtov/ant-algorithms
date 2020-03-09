require 'set'

module AntAlgorithms::TSP
  class AntColonySystem
    attr_reader(
      :distance_matrix,
      :init_pheromone,
      :ant_count,
      :iteration_count,
      :alpha,
      :beta,
      :pheromone_decay_coef,
      :vertex_count,
      :seed_next_vertex,
      :seed_init_vertex,
      :seed_exploits,
      :visability_matrix,
      :pheromone_trail_matrix,
      :exploits_threshold,
      :local_deposited_pheromone,
      :local_pheromone_decay_coef,
      :symm,
      :pheromone_trail_matrix_updater,
      :init_vertex
    )

    def initialize(distance_matrix:, init_pheromone: nil, ant_count:, local_pheromone_decay_coef:, iteration_count: 3000, alpha: 1, beta: 5, pheromone_decay_coef: 0.5, seed_next_vertex: nil, seed_init_vertex: nil, seed_exploits: nil, exploits_threshold: nil, symm: true, init_vertex:nil)
      @distance_matrix = distance_matrix
      @init_pheromone = init_pheromone
      @ant_count = ant_count
      @iteration_count = iteration_count
      @alpha = alpha
      @beta = beta
      @pheromone_decay_coef = pheromone_decay_coef
      @vertex_count = @distance_matrix.row_count
      @seed_next_vertex = seed_next_vertex
      @seed_init_vertex = seed_init_vertex
      @seed_exploits = seed_exploits
      @exploits_threshold = exploits_threshold
      @local_pheromone_decay_coef = local_pheromone_decay_coef
      @symm=symm
      @init_vertex=init_vertex
    end

    def solve
      @local_deposited_pheromone = calculate_local_deposited_pheromone

      @visability_matrix = initialize_visability_matrix(@distance_matrix)
      @init_pheromone ||= @local_deposited_pheromone
      @pheromone_trail_matrix = initialize_pheromone_trail_matrix(vertex_count, init_pheromone)
      @pheromone_trail_matrix_updater = initialize_pheromone_trail_matrix_updater(
        @pheromone_trail_matrix,
        symm
      )
      min_cost = Float::MAX
      best_path = nil

      iteration_count.times.count do
        ant_count.times.each do
          path, cost = build_ant_path

          if cost < min_cost
            best_path = path
            min_cost = cost
          end
        end

        deposited_pheromone = 1.0 / min_cost
        best_path.each_cons(2) do |current_vertex, next_vertex|
          new_pheromone = (1 - pheromone_decay_coef) * @pheromone_trail_matrix[current_vertex, next_vertex] +
            pheromone_decay_coef * deposited_pheromone

          pheromone_trail_matrix_updater.update(current_vertex, next_vertex, new_pheromone)
        end
      end

      [best_path, min_cost]
    end

    private

    def build_ant_path
      remainded_vertex = Set.new([*0..vertex_count-1])

      path = PathBuilder.new(distance_matrix: distance_matrix)

      next_vertex = init_vertex || init_vertex_random_generator.rand(vertex_count)

      remainded_vertex.delete next_vertex
      path << next_vertex

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

        path << next_vertex
        remainded_vertex.delete next_vertex

        current_vertex = next_vertex
      end

      next_vertex = path.path.first
      path << path.path.first

      [path.path, path.cost]
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

    def initialize_visability_matrix(distance_matrix)
      distance_matrix.map { |distance| 1.0 / distance }
    end

    def initialize_pheromone_trail_matrix(row_count, init_pheromone)
      Matrix.build(row_count) { |row, col| row == col ? 0 : init_pheromone }
    end

    def initialize_pheromone_trail_matrix_updater(pheromone_trail_matrix, symm)
      if symm
        AntAlgorithms::SymmPheromoneTrailMatrixUpdater.new(pheromone_trail_matrix)
      else
        AntAlgorithms::AsymmPheromoneTrailMatrixUpdater.new(pheromone_trail_matrix)
      end
    end

    def calculate_local_deposited_pheromone
      _, greedy_cost = GreedyAlgorithm
        .new(
          distance_matrix: distance_matrix,
          seed_init_vertex: seed_init_vertex,
          init_vertex: init_vertex
        )
        .solve

      1.0 / (greedy_cost * distance_matrix.row_count)
    end

    def next_vertex_random_generator
      @next_vertex_random_generator ||= seed_next_vertex ? Random.new(seed_next_vertex) : Random.new
    end

    def exploits_random_generator
      @exploits_random_generator ||= seed_exploits ? Random.new(seed_exploits) : Random.new
    end

    def init_vertex_random_generator
      @init_vertex_random_generator ||= seed_init_vertex ? Random.new(seed_init_vertex) : Random.new
    end
  end
end
