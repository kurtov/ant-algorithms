require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::PMS::AntColonySystem' do
  subject(:ant_colony_system) do
    AntAlgorithms::PMS::AntColonySystem.new(
      processing_times: processing_times,
      due_dates: due_dates,
      init_pheromone: nil,
      ant_count: 20, #140, #20,
      iteration_count: 500, #1000,
      pheromone_decay_coef:  0.9, #0.5 , #0.5,
      seed_next_vertex: 2,
      seed_exploits: 2,
      exploits_threshold: 0.9, #0.5,
      local_pheromone_decay_coef: 0.05, # 0.5, # 0.5,
      mashines_count: mashines_count,
      heuristic: heuristic
    )
  end

  let(:heuristic) { :earliest_due_date }

  describe '#solve' do
    let(:processing_times) { [5, 4, 7, 5, 4, 9] }
    let(:due_dates) { [15, 4, 10, 19, 19, 21] }
    let(:mashines_count) { 2 }
    # task tps1 tpt2        due_dates tardiness
    #      0
    # 1    4    -                4         0
    # 2    4    7                10        0
    # 0    9    7                15        0
    # 3    9   12                19        0
    # 4   13   12                19        0
    # 5   13   21                21        0
    #                   total tardiness:   0
    it 'returns best path and cost' do
      path = ant_colony_system.solve
      expect(path.path).to eq [6, 1, 2, 0, 3, 4, 5]
      expect(path.schedule).to eq [[1, 0, 4], [2, 3, 5]]
      expect(path.cost).to eq 0
    end

    describe '#local_deposited_pheromone' do
      let(:processing_times) { [5, 4, 7] }
      let(:due_dates) { [15, 4, 10] }
      let(:mashines_count) { 2 }

      it 'calculates local_deposited_pheromone' do
        ant_colony_system.solve
        expect(ant_colony_system.local_deposited_pheromone).to eq 1.0/6
      end
    end

    describe '50' do
      before do
        tf = 0.6
        rdd = 0.6
        rnd=Random.new(1)
        @p=50.times.map{rnd.rand(100)}
        p_mean = @p.sum * 1.0 / (mashines_count**2)
        lbound=(p_mean*(1-tf-rdd/2)).to_i
        rbound=(p_mean*(1-tf+rdd/2)).to_i
        diff = rbound - lbound
        @d=50.times.map{lbound + rnd.rand(diff)}
      end


      let(:processing_times) { @p }  # { [37, 12, 72, 9, 75, 5, 79, 64, 16, 1, 76, 71, 6, 25, 50, 20, 18, 84, 11, 28, 29, 14, 50, 68, 87, 87, 94, 96, 86, 13, 9, 7, 63, 61, 22, 57, 1, 0, 60, 81, 8, 88, 13, 47, 72, 30, 71, 3, 70, 21]  }
      let(:due_dates) { @d } # { [994, 746, 948, 1225, 930, 476, 1021, 459, 1253, 769, 1054, 730, 899, 448, 497, 629, 458, 800, 1171, 904, 715, 1098, 1049, 455, 1210, 1140, 559, 712, 814, 789, 588, 746, 1028, 599, 1081, 721, 851, 1211, 712, 1088, 1184, 520, 1226, 676, 781, 1019, 623, 735, 1161, 584] }
      let(:mashines_count) { 2 }
      let(:heuristic) { :modified_due_date }
      # let(:heuristic) { :earliest_due_date }
      # let(:heuristic) { :least_slack }

      xit '' do
        path = ant_colony_system.solve # 13941
        p path.cost
      end
    end
  end
end


    # AntAlgorithms::PMS::AntColonySystem.new(
    #   processing_times: processing_times,
    #   due_dates: due_dates,
    #   init_pheromone: nil,
    #   ant_count: 20, #140, #20,
    #   iteration_count: 1000,
    #   pheromone_decay_coef:  0.9, #0.5 , #0.5,
    #   seed_next_vertex: 1,
    #   seed_exploits: 1,
    #   exploits_threshold: 0.9, #0.5,
    #   local_pheromone_decay_coef: 0.05, # 0.5, # 0.5,
    #   mashines_count: mashines_count,
    #   heuristic: earliest_due_date !
    # )
    # 12447
