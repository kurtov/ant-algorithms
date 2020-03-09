require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::TSP::AntColonySystem' do
  subject(:ant_colony_system) do
    AntAlgorithms::TSP::AntColonySystem.new(
      distance_matrix: distance_matrix,
      init_pheromone: 0.2,
      ant_count: 5,
      iteration_count: 5,
      pheromone_decay_coef: 0.5,
      seed_next_vertex: 1,
      seed_init_vertex: 2,
      seed_exploits: 1,
      exploits_threshold: 0.5,
      local_pheromone_decay_coef: 0.5
    )
  end

  describe '#solve' do
    let(:distance_matrix) do
      Matrix[
        [0.0,  3.0,  4.0,  2.0,  7.0],
        [3.0,  0.0,  4.0,  6.0,  3.0],
        [4.0,  4.0,  0.0,  5.0,  8.0],
        [2.0,  6.0,  5.0,  0.0,  6.0],
        [7.0,  3.0,  8.0,  6.0,  0.0]
      ]
    end

    it 'returns best path and cost' do
      path, cost = ant_colony_system.solve
      expect(path).to eq [0, 2, 1, 4, 3, 0]
      expect(cost).to eq 19
    end
  end

  context '48 vertex' do
    subject(:ant_colony_system) do
      AntAlgorithms::TSP::AntColonySystem.new(
        distance_matrix: distance_matrix,
        beta: 2,
        ant_count: 10,
        iteration_count: 1000,
        pheromone_decay_coef: 0.1, #0.5,
        seed_next_vertex: 1,
        seed_init_vertex: 2,
        seed_exploits: 1,
        exploits_threshold: 0.9,#0.5,
        local_pheromone_decay_coef: 0.1 #0.8
      )
    end

    let(:distance_matrix) do
      Matrix[
        *File.open("spec/support/att48.txt", "r") do |f|
          f.readlines.map { |line| line.split(' ').map(&:to_i) }
        end
      ]
    end

    xit '' do
      best_path, cost = ant_colony_system.solve
      expect(cost).to eq 34991.0
    end
  end
end
