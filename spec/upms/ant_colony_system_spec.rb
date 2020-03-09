require 'ant-algorithms'
require 'matrix'

describe 'AntAlgorithms::UPMS::AntColonySystem' do
  subject(:ant_colony_system) do
    AntAlgorithms::UPMS::AntColonySystem.new(
      processing_times: processing_times,
      due_dates: due_dates,
      weights: weights,
      scaling_param: scaling_param,
      init_pheromone: nil,
      ant_count: 20,
      iteration_count: 250,
      alpha: 1,
      beta: 3,
      pheromone_decay_coef: 0.01,
      local_pheromone_decay_coef: 0.01,
      seed_select_mashine: 1,
      seed_exploits_select_mashine: 2,
      seed_select_job: 3,
      seed_exploits_select_job: 4,
      seed_local_search: 5,
      local_search_iteration_count: local_search_iteration_count,
      exploits_select_mashine_threshold: 0.9,
      exploits_select_job_threshold: 0.9,
      heuristic: heuristic,
    )
  end

  let(:local_search_iteration_count) { 0 }
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
  let(:heuristic) do
    :apparent_tardiness_cost_heuristic
  end

  describe 'solve' do
    it 'returns best path and cost' do
      path = ant_colony_system.solve
      expect(path.schedule).to eq [[1, 0], [2]]
      expect(path.path).to eq [[0, 1], [1, 2], [0, 0]]
      expect(path.cost).to eq 2
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

      let(:local_search_iteration_count) { 50 }
      let(:processing_times) { Matrix[*mashines_count.times.map { @p }] }  # { [37, 12, 72, 9, 75, 5, 79, 64, 16, 1, 76, 71, 6, 25, 50, 20, 18, 84, 11, 28, 29, 14, 50, 68, 87, 87, 94, 96, 86, 13, 9, 7, 63, 61, 22, 57, 1, 0, 60, 81, 8, 88, 13, 47, 72, 30, 71, 3, 70, 21]  }
      let(:due_dates) { @d } # { [994, 746, 948, 1225, 930, 476, 1021, 459, 1253, 769, 1054, 730, 899, 448, 497, 629, 458, 800, 1171, 904, 715, 1098, 1049, 455, 1210, 1140, 559, 712, 814, 789, 588, 746, 1028, 599, 1081, 721, 851, 1211, 712, 1088, 1184, 520, 1226, 676, 781, 1019, 623, 735, 1161, 584] }
      let(:mashines_count) { 2 }
      let(:heuristic) { :modified_due_date }  #{ :apparent_tardiness_cost_heuristic } # { :modified_due_date }
      let(:weights) { Array.new(50) { 1 } }
      let(:scaling_param) { 4 }

      it '' do
        path = ant_colony_system.solve # 13941
        p path.cost
      end
    end
end
