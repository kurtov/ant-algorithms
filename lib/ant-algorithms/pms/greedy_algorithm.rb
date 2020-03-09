module AntAlgorithms::PMS
  class GreedyAlgorithm < AntAlgorithms::SMTTP::GreedyAlgorithm
    attr_reader(
      :mashines_count
    )

    def initialize(mashines_count:, **options)
      super(options)

      @mashines_count = mashines_count
    end

    def initialize_path_builder
      PathBuilder.new(
        processing_times: processing_times,
        due_dates: due_dates,
        mashines_count: mashines_count
      )
    end
  end
end
