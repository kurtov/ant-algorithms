require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::TSP::AntSystem' do
  subject(:ant_system) do
    AntAlgorithms::TSP::AntSystem.new(
      distance_matrix: distance_matrix,
      init_pheromone: 0.2,
      ant_count: 1,
      iteration_count: 1,
      pheromone_decay_coef: 0.5,
      seed_next_vertex: 1,
      seed_init_vertex: 2
    )
  end

  context 'Matrix[ [0,2], [2,0] ]' do
    let(:distance_matrix) do
      Matrix[ [0,2], [2,0] ]
    end

    describe '#visability_matrix' do
      it 'cacluates visability matrix' do
        ant_system.solve
        expect(ant_system.visability_matrix[0, 1]).to eq 0.5
      end
    end

    describe '#pheromone_trail_matrix' do
      # cost == 4
      # deposite_pheromone = 1/cost * 2 = 0.5 # edge [0,1] and [1,0] used in decision
      # init_pheromone = 0.2
      # pheromone_decay_coef = 0.5
      # new_trail = init_pheromone * (1 - pheromone_decay_coef) + deposite_pheromone
      # 0.2 * 0.5 + 0.5 = 0.6
      it 'cacluates pheromone_trail_matrix' do
        ant_system.solve
        expect(ant_system.pheromone_trail_matrix[0, 1]).to eq 0.6
      end
    end

    describe '#solve' do
      it 'returns best path and cost' do
        best_path, cost = ant_system.solve
        expect(best_path).to eq [0,1,0]
        expect(cost).to eq 4
      end
    end
  end

  context '5 vertex' do
    let(:distance_matrix) do
      Matrix[
        [0.0,  3.0,  4.0,  2.0,  7.0],
        [3.0,  0.0,  4.0,  6.0,  3.0],
        [4.0,  4.0,  0.0,  5.0,  8.0],
        [2.0,  6.0,  5.0,  0.0,  6.0],
        [7.0,  3.0,  8.0,  6.0,  0.0]
      ]
    end

    subject(:ant_system) do
      AntAlgorithms::TSP::AntSystem.new(
        distance_matrix: distance_matrix,
        init_pheromone: 0.2,
        ant_count: 5,
        iteration_count: 5,
        pheromone_decay_coef: 0.5,
        seed_next_vertex: 1,
        seed_init_vertex: 2
      )
    end

    describe '#solve' do
      it 'returns best path and cost' do
        best_path, cost = ant_system.solve
        expect(cost).to eq 19
      end
    end
  end

  # context '48 vertex' do
  #   subject(:ant_system) do
  #     AntAlgorithms::TSP::AntSystem.new(
  #       distance_matrix: distance_matrix,
  #       init_pheromone: 0.2,
  #       ant_count: 100,
  #       iteration_count: 1000,
  #       pheromone_decay_coef: 0.5,
  #       seed_next_vertex: 1,
  #       seed_init_vertex: 2
  #     )
  #   end

  #   let(:distance_matrix) do
  #     Matrix[
  #       *File.open("spec/support/att48.txt", "r") do |f|
  #         f.readlines.map { |line| line.split(' ').map(&:to_i) }
  #       end
  #     ]
  #   end

  #   it '' do
  #     best_path, cost = ant_system.solve
  #     expect(cost).to eq 34991.0
  #   end
  # end
end
