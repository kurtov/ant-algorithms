class AntAlgorithms::UPMS::LocalSearch
  # Job swaps on different machines: randomly choose two machines i1 and i2,
  # and then randomly choose two jobs,
  # j1 from machine i1 and j2 from machine i2.
  # Swap jobs j1 and j2.
  class LS2
    attr_reader(
      :processing_times,
      :due_dates,
      :weights,
      :random_generator
    )

    def initialize(processing_times:, due_dates:, weights:, random_generator:)
      @processing_times = processing_times
      @due_dates = due_dates
      @weights = weights
      @random_generator = random_generator
    end

    def neighbor(path)
      path_builder = initialize_path_builder

      return path if processing_times.row_count < 2

      mashine1_number = random_generator.rand(processing_times.row_count)
      mashine2_number = mashine1_number
      while mashine2_number == mashine1_number
        mashine2_number = random_generator.rand(processing_times.row_count)
      end

      jobs_on_mashine1 = path.schedule[mashine1_number].dup
      return path if jobs_on_mashine1.count < 1

      jobs_on_mashine2 = path.schedule[mashine2_number].dup
      return path if jobs_on_mashine2.count < 1

      job1_position = random_generator.rand(jobs_on_mashine1.count)
      job2_position = random_generator.rand(jobs_on_mashine2.count)

      job1_number = jobs_on_mashine1[job1_position]
      jobs_on_mashine1[job1_position] = jobs_on_mashine2[job2_position]
      jobs_on_mashine2[job2_position] = job1_number

      #todo: optimization
      jobs_on_mashine1.each do |job_number|
        path_builder.add(mashine1_number, job_number)
      end

      jobs_on_mashine2.each do |job_number|
        path_builder.add(mashine2_number, job_number)
      end

      processing_times.row_count.times.each do |mashine_number|
        next if mashine1_number == mashine_number
        next if mashine2_number == mashine_number

        path.schedule[mashine_number].each do |job_number|
          path_builder.add(mashine_number, job_number)
        end
      end

      path_builder.build
    end

    private

    def initialize_path_builder
      AntAlgorithms::UPMS::PathBuilder.new(
        processing_times: processing_times,
        due_dates: due_dates,
        weights: weights
      )
    end
  end
end
