module AntAlgorithms::PMS
  class AntColonySystem < AntAlgorithms::SMTTP::AntColonySystem
    attr_reader(
      :mashines_count
    )

    def initialize(mashines_count:, **options)
      super(options)

      @mashines_count = mashines_count
    end

    def initialize_path_builder
      PathBuilder.new(
        processing_times: extended_processing_times,
        due_dates: extended_due_dates,
        mashines_count: mashines_count
      )
    end
  end
end
