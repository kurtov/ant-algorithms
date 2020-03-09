require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::UPMS::MashineReselector' do
  subject(:mashine_reselector) do
    AntAlgorithms::UPMS::MashineReselector.new(
      processing_times: processing_times,
      due_dates: due_dates
    )
  end
  let(:processing_times) do
    Matrix[
      [2,3,4],
      [3,4,5]
    ]
  end
  let(:due_dates) do
    [3,10,5]
  end

  describe '#reselect_mashine' do
    let(:makespans) { [2, 3] }
    let(:job_number) { 1 }

    # p tardiness
    # 2 2+2-10=-6
    # 3 3+3-10=-4
    # min processing_time: [2,4].min=2 => mashine_number == 0
    it do
      expect(mashine_reselector.reselect_mashine(makespans, job_number)).to eq(0)
    end

    context 'when there are tardiness' do
      let(:makespans) { [12, 10] }

      # p tardiness
      # 2 12+2-10=4
      # 3 10+3-10=3
      # min tardiness [4,3].min=3 => mashine_number == 1
      it do
        expect(mashine_reselector.reselect_mashine(makespans, job_number)).to eq(1)
      end

    end
  end
end
