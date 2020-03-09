class AntAlgorithms::UPMS::LocalSearch
  # Job insertion: randomly choose one job j1 and one
  # machine i2, where j1 does not belong to i2. Randomly choose a
  # valid position r in i2. Transfer job j1 to i2 at position r
  class LS3
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

      # may be better choose job instead mashine->job
      mashine1_number = random_generator.rand(processing_times.row_count)
      mashine2_number = mashine1_number
      while mashine2_number == mashine1_number
        mashine2_number = random_generator.rand(processing_times.row_count)
      end

      jobs_on_mashine1 = path.schedule[mashine1_number].dup
      return path if jobs_on_mashine1.count < 1

      jobs_on_mashine2 = path.schedule[mashine2_number].dup

      job1_position = random_generator.rand(jobs_on_mashine1.count)
      insert_position = random_generator.rand(jobs_on_mashine2.count+1)

      job1_number = jobs_on_mashine1.delete_at(job1_position)
      jobs_on_mashine2.insert(insert_position, job1_number)

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
