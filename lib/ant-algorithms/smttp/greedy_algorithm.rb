require 'set'

module AntAlgorithms::SMTTP
  class GreedyAlgorithm
    attr_reader(
      :processing_times,
      :due_dates,
      :heuristic
    )

    def initialize(processing_times:, due_dates:, heuristic: :earliest_due_date)
      @processing_times = [*processing_times, 0]
      @due_dates = [*due_dates, 0]
      @heuristic = heuristic
    end

    def solve
      # @visability_matrix = initialize_visability_matrix #(due_dates)
      # @path_builder = Path.new(processing_times: processing_times, due_dates: due_dates)

      build_ant_path
    end

    private

    def build_ant_path
      @visability_matrix = initialize_visability_matrix #(due_dates)
      path_builder = initialize_path_builder

      vertex_count = @visability_matrix.row_count
      remainded_vertex = Set.new([*0..vertex_count-1])

      next_vertex = vertex_count-1

      remainded_vertex.delete next_vertex
      path_builder << next_vertex

      current_vertex = next_vertex
      until remainded_vertex.empty?
        visabilities = @visability_matrix.row(current_vertex)

        ant_decision_table = remainded_vertex.map do |vertex|
          [vertex, visabilities[vertex]]
        end

        next_vertex = apply_ant_decision_policy(ant_decision_table)

        remainded_vertex.delete next_vertex
        path_builder << next_vertex

        @visability_matrix = modify_visability_matrix(path_builder.total_processing_time)

        current_vertex = next_vertex
      end

      path_builder.build
    end

    def initialize_path_builder
      PathBuilder.new(
        processing_times: processing_times,
        due_dates: due_dates
      )
    end

    def apply_ant_decision_policy(ant_decision_table)
      ant_decision_table
        .max_by{ |_, visability| visability }
        .first
    end

    def initialize_visability_matrix
      heuristic_class(@heuristic)
        .new(
          processing_times: processing_times,
          due_dates: due_dates
        ).build_matrix
    end

    def modify_visability_matrix(total_processing_time)
      heuristic_class(@heuristic)
        .new(
          processing_times: processing_times,
          due_dates: due_dates
        ).build_matrix(total_processing_time)
    end

    def heuristic_class(heuristic)
      case heuristic.to_sym
      when :earliest_due_date
        EarliestDueDateHeuristic
      when :least_slack
        LeastSlackHeuristic
      when :modified_due_date
        ModifiedDueDateHeuristic
      end
    end
  end
end
