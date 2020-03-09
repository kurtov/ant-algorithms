require 'ant-algorithms'

describe 'AntAlgorithms::SMTTP::GreedyAlgorithm' do
  let(:processing_times) { [5, 4, 7] }
  let(:due_dates) { [15, 4, 10] }
  let(:heuristic) { :earliest_due_date }
  let(:greedy_algorithm) do
    AntAlgorithms::SMTTP::GreedyAlgorithm.new(
      processing_times: processing_times,
      due_dates: due_dates,
      heuristic: heuristic
    )
  end

  describe 'solve' do
    it 'returns best path and cost' do
      path = greedy_algorithm.solve

      expect(path.path).to eq [3, 1, 2, 0] # 3-addition vertex
      expect(path.schedule).to eq [1, 2, 0]
      expect(path.cost).to eq 2
    end
  end

  describe '1' do
    let(:due_dates) { [10, 15, 20, 25] }
    let(:processing_times) { [8, 14, 7, 15] }

    describe 'earliest_due_date' do
      let(:heuristic) { :earliest_due_date }

      it { expect(greedy_algorithm.solve.cost).to eq 35 }
      it { expect(greedy_algorithm.solve.schedule).to eq [0,1,2,3] }
    end

    describe 'earliest_due_date' do
      let(:heuristic) { :least_slack }

      it { expect(greedy_algorithm.solve.cost).to eq 48 }
      it { expect(greedy_algorithm.solve.schedule).to eq [1,0,3,2] }
    end

    describe 'modified_due_date' do
      let(:heuristic) { :modified_due_date }

      it { expect(greedy_algorithm.solve.cost).to eq 33 }
      it { expect(greedy_algorithm.solve.schedule).to eq [0,2,1,3] }
    end
  end
end
