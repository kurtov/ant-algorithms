class AntAlgorithms
  class RandomValueGenerator
    def initialize(frequencies, random_generator: Random.new)
      @frequencies = frequencies
      @random_generator = random_generator
      @cummulative_destribution = build_cummulative_destribution(frequencies)
    end

    def rand
      max_value = @cummulative_destribution.last.last.end

      if max_value.infinite?
        rand_value_from_infinite_frequencies
      else
        rand_value_from_cummulative_destribution
      end
    end

    private

    def build_cummulative_destribution(frequencies)
      sum = 0.0
      frequencies.map { |value, frequency| [value, (sum...sum+=frequency)] }
    end

    def rand_value_from_cummulative_destribution
      last_interval = @cummulative_destribution.last.last
      rnd = @random_generator.rand(last_interval.end)

      @cummulative_destribution
        .find { |_, interval| interval.include?(rnd) }
        .first
    end

    def rand_value_from_infinite_frequencies
      inf_frequencies = @frequencies.select { |_, frequency| frequency.infinite? }
      rnd = @random_generator.rand(inf_frequencies.count)
      inf_frequencies[rnd].first
    end
  end
end
