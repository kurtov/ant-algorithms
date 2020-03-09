require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::UPMS::GreedyAlgorithm' do
  subject(:greedy_algorithm) do
    AntAlgorithms::UPMS::GreedyAlgorithm.new(
      scaling_param: scaling_param,
      processing_times: processing_times,
      due_dates: due_dates,
      weights: weights,
      heuristic: heuristic
    )
  end
  let(:scaling_param) { 2 }
  let(:processing_times) do
    Matrix[
      [5, 4, 7],
      [5, 4, 7]
    ]
  end
  let(:due_dates) do
    [8, 4, 6]
  end
  let(:weights) do
    [1,1,1]
  end
  let(:heuristic) do
    :apparent_tardiness_cost_heuristic
  end

  describe 'solve' do
    it 'returns best path and cost' do
      path = greedy_algorithm.solve
      expect(path.schedule).to eq [[1, 2], [0]]
      expect(path.path).to eq [[0, 1], [1, 0], [0, 2]]
      expect(path.cost).to eq 5
    end
  end
end
