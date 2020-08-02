require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::CUPMS::MashineReselector' do
  subject(:mashine_reselector) do
    AntAlgorithms::CUPMS::MashineReselector.new(processing_times: processing_times)
  end
  let(:processing_times) do
    Matrix[
      [2,3,4],
      [3,4,5]
    ]
  end

  describe '#reselect_mashine' do
    let(:mashine0) { AntAlgorithms::CUPMS::GreedyAlgorithm::Mashine.new(0, 2, nil) }
    let(:mashine1) { AntAlgorithms::CUPMS::GreedyAlgorithm::Mashine.new(1, 3, nil) }

    let(:job) { AntAlgorithms::CUPMS::GreedyAlgorithm::Job.new(1, 10) }

    # p tardiness
    # 3 2+3-10=-5
    # 4 3+4-10=-3
    # min processing_time: [2,4].min=2 => mashine_number == 0
    it do
      mashine = mashine_reselector.reselect_mashine(job: job, mashines: [mashine0, mashine1])
      expect(mashine).to eq(mashine0)
    end

    context 'when there are tardiness' do
      let(:mashine0) { AntAlgorithms::CUPMS::GreedyAlgorithm::Mashine.new(0, 12, nil) }
      let(:mashine1) { AntAlgorithms::CUPMS::GreedyAlgorithm::Mashine.new(1, 10, nil) }

      # p tardiness
      # 3 12+3-10=5
      # 4 10+4-10=4
      # min tardiness [5,4].min=4 => mashine_number == 1
      it do
        mashine = mashine_reselector.reselect_mashine(job: job, mashines: [mashine0, mashine1])
        expect(mashine).to eq(mashine1)
      end
    end
  end
end
