class AntAlgorithms
  class AsymmPheromoneTrailMatrixUpdater;
    def initialize(matrix)
      @matrix=matrix
    end

    def update(vertex_from, vertex_to, pheromone)
      @matrix[vertex_from, vertex_to] = pheromone
    end
  end
end
