class AntAlgorithms
  class SymmPheromoneTrailMatrixUpdater
    def initialize(matrix)
      @matrix=matrix
    end

    def update(vertex_from, vertex_to, pheromone)
      @matrix[vertex_from, vertex_to] = pheromone
      @matrix[vertex_to, vertex_from] = pheromone
    end
  end
end
