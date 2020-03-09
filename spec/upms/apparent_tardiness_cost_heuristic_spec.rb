require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::UPMS::ApparentTardinessCostHeuristic' do
  subject(:heuristic) do
    AntAlgorithms::UPMS::ApparentTardinessCostHeuristic.new(
      scaling_param: scaling_param,
      processing_times: processing_times,
      due_dates: due_dates,
      weights: weights
    )
  end
  let(:scaling_param) { 2 }
  let(:processing_times) do
    Matrix[
      [2,3,4],
      [3,4,5]
    ]
  end
  let(:due_dates) do
    [3,10,5]
  end
  let(:weights) do
    [6,7,8]
  end

  describe '#build' do
    let(:h0) { 6/2.0 * Math.exp(-(6*[3-2-2,0].max)/(2*(2+3+4)/3.0)) }
    let(:h1) { 7/3.0 * Math.exp(-(7*[10-3-2,0].max)/(2*(2+3+4)/3.0)) }

    it do
      expect(heuristic.build(mashine_number:0, makespan: 2, remainded_jobs: [0, 1]))
        .to eq([[0,h0],[1,h1]])
    end
  end
end
