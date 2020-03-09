module AntAlgorithms::TSP
  class PathBuilder
    attr_reader :path, :cost

    def initialize(distance_matrix:)
      @distance_matrix = distance_matrix
      @path = []
      @cost = 0
    end

    def <<(vertex)
      @cost += @distance_matrix[path.last, vertex] if path.size > 0
      @path << vertex
    end
  end
end
