require 'ant-algorithms'

describe 'AntAlgorithms::SMTTP::PathBuilder' do
  let(:processing_times) { [0, 5, 4, 7] }
  let(:due_dates) { [0, 15, 4, 10] }
  let(:path_builder) do
    AntAlgorithms::SMTTP::PathBuilder.new(processing_times: processing_times, due_dates: due_dates)
  end
  let(:path) do
    path_builder << 0
    path_builder << 2
    path_builder << 3
    path_builder << 1

    path_builder.build
  end

  describe '<<' do
    it 'adds vertex to path' do
      expect(path.path).to eq [0, 2, 3, 1]
    end

    it 'changes cost' do
      expect(path.cost).to eq 2
    end
  end
end
