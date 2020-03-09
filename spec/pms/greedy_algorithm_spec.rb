require 'ant-algorithms'

describe 'AntAlgorithms::PMS::GreedyAlgorithm' do
  let(:processing_times) { [5, 4, 7] }
  let(:due_dates) { [8, 4, 6] }
  let(:mashines_count) { 2 }
  let(:greedy_algorithm) do
    AntAlgorithms::PMS::GreedyAlgorithm.new(
      processing_times: processing_times,
      due_dates: due_dates,
      mashines_count: mashines_count
    )
  end

  describe 'solve' do
    it 'returns best path and cost' do
      path = greedy_algorithm.solve
      expect(path.schedule).to eq [[1, 0], [2]]
      expect(path.path).to eq [3, 1, 2, 0] # 3 - addition vertex
      expect(path.cost).to eq 2
    end
  end
end
