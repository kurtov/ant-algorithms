require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::CUPMS::GreedyAlgorithm' do
  subject(:greedy_algorithm) do
    AntAlgorithms::CUPMS::GreedyAlgorithm.new(
      scaling_param: scaling_param,
      processing_times: processing_times,
      due_dates: due_dates,
      weights: weights,
      drops: drops,
      shifts: shifts,
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
  let(:shifts) do
    [
      [0,12],
      [0,13]
    ]
  end
  let(:drops) do
    [5,5,7]
  end
  let(:heuristic) do
    :apparent_tardiness_cost_heuristic
  end

  context 'when there are not mashines' do
    let(:shifts) { [] }

    describe 'solve' do
      it 'returns best path and cost' do
        path = greedy_algorithm.solve

        expect(path.path).to eq []
        expect(path.cost).to eq 17
        expect(path.schedule).to eq []
        expect(path.dropped_job_numbers).to eq [0, 1, 2]
      end
    end
  end

  context 'when there are not jobs' do
    let(:due_dates) do
      []
    end
    let(:weights) do
      []
    end
    let(:drops) do
      []
    end

    describe 'solve' do
      it 'returns best path and cost' do
        path = greedy_algorithm.solve

        expect(path.path).to eq []
        expect(path.cost).to eq 0
        expect(path.schedule).to eq [[],[]]
        expect(path.dropped_job_numbers).to eq []
      end
    end
  end

  context 'when there is one mashine' do

  end

  describe 'solve' do
    it 'returns best path and cost' do
      path = greedy_algorithm.solve
      expect(path.schedule).to eq [[1, 2], [0]]
      expect(path.path).to eq [[0, 1], [1, 0], [0, 2]]
      expect(path.cost).to eq 5
    end

    context 'when shift start greater then 0' do
      let(:shifts) do
        [
          [1,12],
          [4,13]
        ]
      end

      it 'returns best path and cost' do
        path = greedy_algorithm.solve
        expect(path.schedule).to eq [[1, 2], [0]]
        expect(path.path).to eq [[0, 1], [1, 0], [0, 2]]
        expect(path.cost).to eq 8
      end
    end

    context 'when shifts do not have enough capacity' do
      let(:shifts) do
        [
          [1,10],
          [4,13]
        ]
      end

      it 'returns best path and cost' do
        path = greedy_algorithm.solve
        expect(path.schedule).to eq [[1], [0]]
        expect(path.path).to eq [[0, 1], [1, 0]]
        expect(path.cost).to eq 9
        expect(path.dropped_job_numbers).to eq [2]
      end
    end
  end
end
