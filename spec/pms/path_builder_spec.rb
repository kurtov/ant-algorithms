require 'ant-algorithms'

describe 'AntAlgorithms::PMS::PathBuilder' do
  let(:processing_times) { [0, 5, 4, 7] }
  let(:due_dates) { [0, 5, 4, 6] }
  let(:path_builder) do
    AntAlgorithms::PMS::PathBuilder.new(
      processing_times: processing_times,
      due_dates: due_dates,
      mashines_count: 2
    )
  end
  let(:path) do
    path_builder << 0
    path_builder << 2
    path_builder << 3
    path_builder << 1

    path_builder.build
  end

  describe '<<' do
    it 'adds vertex to schedule' do
      #!!! first point ignored
      # expect(path.schedule).to eq [[0, 2, 1], [3]]
      expect(path.schedule).to eq [[2, 1], [3]]
    end

    it 'changes cost' do
      expect(path.cost).to eq 5
    end

    it 'changes path' do
      expect(path.path).to eq [0, 2, 3, 1]
    end
  end
end
