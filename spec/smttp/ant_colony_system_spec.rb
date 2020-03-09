require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::SMTTP::AntColonySystem' do
  subject(:ant_colony_system) do
    AntAlgorithms::SMTTP::AntColonySystem.new(
      processing_times: processing_times,
      due_dates: due_dates,
      init_pheromone: nil,
      ant_count: 20,
      iteration_count: 1000,
      pheromone_decay_coef:  0.5,
      seed_next_vertex: 1,
      seed_exploits: 1,
      exploits_threshold: 0.5,
      local_pheromone_decay_coef: 0.5
    )
  end

  describe '#solve' do
    let(:processing_times) { [5, 4, 7, 5, 4, 9] }
    let(:due_dates) { [15, 4, 10, 19, 19, 21] }

    # task total_processint_time due_dates tardiness
    #      0
    # 1    4                     4         0
    # 2    11                    10        1
    # 0    16                    15        1
    # 4    20                    19        1
    # 3    25                    19        6
    # 5    34                    21        13
    #                   total tardiness:   22
    it 'returns best path and cost' do
      path = ant_colony_system.solve
      expect(path.path).to eq [6, 1, 2, 0, 4, 3, 5] # 6 - addition vertex
      expect(path.schedule).to eq [1, 2, 0, 4, 3, 5]
      expect(path.cost).to eq 22
    end

    describe '#local_deposited_pheromone' do
      let(:processing_times) { [5, 4, 7] }
      let(:due_dates) { [15, 4, 10] }

      it 'calculates local_deposited_pheromone' do
        ant_colony_system.solve
        expect(ant_colony_system.local_deposited_pheromone).to eq 1.0/6
      end
    end

    describe '50' do
      # rnd=Random.new(1)
      # p=50.times.map{rnd.rand(100)}
      # lbound=(p.inject(&:+)*(1-tf-rdd/2)).to_i
      # rbound=(p.inject(&:+)*(1-tf+rdd/2)).to_i
      # diff = rbound - lbound
      # d=50.times.map{lbound + rnd.rand(diff)}

      let(:processing_times) { [37, 12, 72, 9, 75, 5, 79, 64, 16, 1, 76, 71, 6, 25, 50, 20, 18, 84, 11, 28, 29, 14, 50, 68, 87, 87, 94, 96, 86, 13, 9, 7, 63, 61, 22, 57, 1, 0, 60, 81, 8, 88, 13, 47, 72, 30, 71, 3, 70, 21]  }
      let(:due_dates) { [994, 746, 948, 1225, 930, 476, 1021, 459, 1253, 769, 1054, 730, 899, 448, 497, 629, 458, 800, 1171, 904, 715, 1098, 1049, 455, 1210, 1140, 559, 712, 814, 789, 588, 746, 1028, 599, 1081, 721, 851, 1211, 712, 1088, 1184, 520, 1226, 676, 781, 1019, 623, 735, 1161, 584] }

      xit '' do
        path, cost = ant_colony_system.solve
        p cost #greedy 18337
      end
    end
  end
end
