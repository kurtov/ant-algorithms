require 'matrix'

class ModifiedDueDateHeuristic
  def initialize(due_dates:, processing_times:)
    @due_dates=due_dates
    @processing_times=processing_times
  end

  def build_matrix(current_processint_time=0)
    @matrix ||= Matrix.build(@due_dates.size) do |row, col|
      (row == col) ? 0 : 1.0 / [current_processint_time + @processing_times[col], @due_dates[col]].max
    end
  end
end
