require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::TSP::GreedyAlgorithm' do
  subject(:greedy_algorithm) do
    AntAlgorithms::TSP::GreedyAlgorithm.new(
      distance_matrix: distance_matrix,
      seed_init_vertex: 2
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
      path, cost = greedy_algorithm.solve
      expect(path).to eq [0, 3, 2, 1, 4, 0]
      expect(cost).to eq 21
    end

    context 'when init_vertex is specified' do
      subject(:greedy_algorithm) do
        AntAlgorithms::TSP::GreedyAlgorithm.new(
          distance_matrix: distance_matrix,
          init_vertex: 2
        )
      end

      it 'returns best path and cost' do
        path, cost = greedy_algorithm.solve
        expect(path).to eq [2, 0, 3, 1, 4, 2]
        expect(cost).to eq 23
      end
    end
  end
end
