require 'matrix'

class EarliestDueDateHeuristic
  def initialize(due_dates:, **options)
    @due_dates=due_dates
  end

  def build_matrix(*)
    @matrix ||= Matrix.build(@due_dates.size) do |row, col|
      (row == col) ? 0 : 1.0 / @due_dates[col]
    end
  end
end
