require 'set'

module AntAlgorithms::TSP
  class GreedyAlgorithm
    attr_reader(
      :distance_matrix,
      :visability_matrix,
      :seed_init_vertex,
      :init_vertex
    )

    def initialize(distance_matrix:, seed_init_vertex: nil, init_vertex: nil)
      @distance_matrix = distance_matrix
      @seed_init_vertex = seed_init_vertex
      @init_vertex = init_vertex
    end

    def solve
      @visability_matrix = initialize_visability_matrix(@distance_matrix)

      build_ant_path
    end

    private

    def build_ant_path
      vertex_count = @distance_matrix.row_count
      remainded_vertex = Set.new([*0..vertex_count-1])
      path = PathBuilder.new(distance_matrix: distance_matrix)

      next_vertex = init_vertex || init_vertex_random_generator.rand(vertex_count)

      remainded_vertex.delete next_vertex
      path << next_vertex

      current_vertex = next_vertex
      until remainded_vertex.empty?
        visabilities = visability_matrix.row(current_vertex)

        ant_decision_table = remainded_vertex.map do |vertex|
          [vertex, visabilities[vertex]]
        end

        next_vertex = apply_ant_decision_policy(ant_decision_table)

        remainded_vertex.delete next_vertex
        path << next_vertex

        current_vertex = next_vertex
      end

      path << path.path.first

      [path.path, path.cost]
    end

    def apply_ant_decision_policy(ant_decision_table)
      ant_decision_table
        .max_by{ |_, visability| visability }
        .first
    end

    def init_vertex_random_generator
      @init_vertex_random_generator ||= seed_init_vertex ? Random.new(seed_init_vertex) : Random.new
    end

    def initialize_visability_matrix(distance_matrix)
      distance_matrix.map { |distance| 1.0 / distance }
    end
  end
end
