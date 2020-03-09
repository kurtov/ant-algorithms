module AntAlgorithms::UPMS
  class LocalSearch
    attr_reader(
      :processing_times,
      :due_dates,
      :weights,
      :random_generator,
      :iterations_count
    )

    def initialize(processing_times:, due_dates:, weights:, random_generator:, iterations_count: 1)
      @processing_times = processing_times
      @due_dates = due_dates
      @weights = weights
      @random_generator = random_generator
      @iterations_count = iterations_count
    end

    def search(path)
      iteration = 0
      while iteration < iterations_count
        k=0
        while k < strategies.count
          strategy = strategies[k]
          new_path = strategy.neighbor(path)
          if new_path.cost < path.cost
            path = new_path
            k=0
          else
            k+=1
          end
        end
        iteration+=1
      end

      path
    end

    def strategies
      @strategies = [LS1, LS2, LS3].map do |klass|
        klass.new(
          processing_times: processing_times,
          due_dates: due_dates,
          weights: weights,
          random_generator: random_generator
        )
      end
    end
  end
end

require_relative 'local_search/ls1'
require_relative 'local_search/ls2'
require_relative 'local_search/ls3'
