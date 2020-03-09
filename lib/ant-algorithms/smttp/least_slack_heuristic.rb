require 'matrix'
require "byebug"

class LeastSlackHeuristic
  def initialize(due_dates:, processing_times:)
    @due_dates=due_dates
    @processing_times=processing_times
  end

  def build_matrix(*)
    @matrix ||= begin
      diffs = @due_dates.zip(@processing_times).map do |due_date, processing_times|
        due_date - processing_times
      end

      # fix cases when due_date >= processing_times
      # extended_poing always has value == 0. Thus matrix will be baised
      min_diff = diffs.select { |value| value <= 0}.min
      if min_diff
        diffs.map! { |v| v - min_diff + 1 }
      end
  # byebug
      Matrix.build(@due_dates.size) do |row, col|
        (row == col) ? 0 : 1.0 / diffs[col]
      end
    end
  end
end
