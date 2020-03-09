require 'set'

module AntAlgorithms::TSP
  class AntSystem
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
      :visability_matrix,
      :pheromone_trail_matrix,
    )

    def initialize(distance_matrix:, init_pheromone:, ant_count:, iteration_count: 3000, alpha: 1, beta: 5, pheromone_decay_coef: 0.5, seed_next_vertex: nil, seed_init_vertex: nil)
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
    end

    def solve
      raise unless @distance_matrix.square?
      raise if @init_pheromone <= 0
      @visability_matrix = initialize_visability_matrix(@distance_matrix)
      @pheromone_trail_matrix = initialize_pheromone_trail_matrix(vertex_count, init_pheromone)
      min_cost = Float::MAX
      best_path = nil

      iteration_count.times.count do
        deposited_pheromone_matrix = initialize_deposited_pheromone_matrix(vertex_count)

        ant_count.times.each do
          path, cost = build_ant_path
          path.each_cons(2) do |current_vertex, next_vertex|
            deposited_pheromone_matrix[current_vertex, next_vertex] += 1 / cost
            deposited_pheromone_matrix[next_vertex, current_vertex] += 1 / cost
          end

          if cost < min_cost
            best_path = path
            min_cost = cost
          end
        end

        @pheromone_trail_matrix =
          @pheromone_trail_matrix.map { |trail| trail * (1 - pheromone_decay_coef) } +
          deposited_pheromone_matrix
      end

      [best_path, min_cost]
    end

    private

    def build_ant_path
      remainded_vertex = Set.new([*0..vertex_count-1])
      tabu_list = Set.new()
      path = []

      init_vertex = init_vertex_random_generator.rand(vertex_count)

      path << init_vertex
      remainded_vertex.delete init_vertex
      tabu_list.add(init_vertex)

      cost = 0.0
      current_vertex = init_vertex

      until remainded_vertex.empty?
        visabilities = visability_matrix.row(current_vertex)
        pheromone_trails = pheromone_trail_matrix.row(current_vertex)

        ant_decision_table = remainded_vertex.map do |vertex|
          [vertex, pheromone_trails[vertex]**alpha * visabilities[vertex]**beta]
        end

        next_vertex = apply_ant_decision_policy(ant_decision_table)

        path << next_vertex
        remainded_vertex.delete next_vertex
        tabu_list.add(next_vertex)

        cost += distance_matrix[current_vertex, next_vertex]
        current_vertex = next_vertex
      end

      path << init_vertex
      cost += distance_matrix[current_vertex, init_vertex]
      [path, cost]
    end

    def apply_ant_decision_policy(ant_decision_table)
      AntAlgorithms::RandomValueGenerator
        .new(ant_decision_table, random_generator: next_vertex_random_generator)
        .rand
    end

    def initialize_deposited_pheromone_matrix(row_count)
      Matrix.build(row_count) { 0 }
    end

    def initialize_visability_matrix(distance_matrix)
      distance_matrix.map { |distance| 1.0 / distance }
    end

    def initialize_pheromone_trail_matrix(row_count, init_pheromone)
      Matrix.build(row_count) { |row, col| row == col ? 0 : init_pheromone }
    end

    def next_vertex_random_generator
      @next_vertex_random_generator ||= seed_next_vertex ? Random.new(seed_next_vertex) : Random.new
    end

    def init_vertex_random_generator
      @init_vertex_random_generator ||= seed_init_vertex ? Random.new(seed_init_vertex) : Random.new
    end
  end
end






