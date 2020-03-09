class AntAlgorithms::UPMS::LocalSearch
  # Job swaps on one machine: randomly choose a machine i,
  # and then randomly choose two jobs, j1 and j2 from machine i.
  # Swap jobs j1 and j2.
  class LS1
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
      mashine1_number = random_generator.rand(processing_times.row_count)
      jobs = path.schedule[mashine1_number]

      return path if jobs.count < 2

      job1_position = random_generator.rand(jobs.count)
      job2_position = job1_position
      while job2_position == job1_position
        job2_position = random_generator.rand(jobs.count)
      end

      schedule = path.schedule[mashine1_number].dup
      job1_number = schedule[job1_position]
      schedule[job1_position] = schedule[job2_position]
      schedule[job2_position] = job1_number

      #todo: optimization
      schedule.each do |job_number|
        path_builder.add(mashine1_number, job_number)
      end

      processing_times.row_count.times.each do |mashine_number|
        next if mashine1_number == mashine_number

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
