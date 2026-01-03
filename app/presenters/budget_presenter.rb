# frozen_string_literal: true

class BudgetPresenter < SimpleDelegator
  def initialize(budget, date)
    super(budget)

    @budget = budget
    @date = date
  end

  def total_spent
    @total_spent ||= calculate_total_spent
  end

  def percent_spent
    (total_spent.to_f / budget.amount) * 100
  end

  def percent_of_month
    return 100 if date != Date.current.beginning_of_month

    (Date.current.day / Date.current.end_of_month.day.to_f) * 100
  end

  # Returns HSL color for progress bar based on how far over expected pace
  # Green when on track, gradually shifts to red as overspending increases
  # More forgiving early in the month, stricter late in the month
  def progress_bar_color
    "hsl(#{progress_bar_hue}, 71%, 48%)"
  end

  # Returns contrasting color for the "today" marker line
  # White when bar is reddish (hue < 60), dark otherwise
  def progress_marker_color
    progress_bar_hue < 60 ? "#ffffff" : "#363636"
  end

  attr_reader :date

  private

  attr_reader :budget

  def progress_bar_hue
    @progress_bar_hue ||= calculate_progress_bar_hue
  end

  def calculate_progress_bar_hue
    excess = percent_spent - percent_of_month

    if excess <= 0
      141
    else
      # Tolerance decreases as month progresses:
      # - Early month (day 1-10): ~45% excess needed for full red
      # - Mid month: ~25% excess
      # - Late month (day 25+): ~10% excess for full red
      month_progress = percent_of_month / 100.0
      max_tolerance = 50 - (40 * month_progress)
      ratio = [ excess / max_tolerance, 1.0 ].min
      (141 * (1 - ratio)).round
    end
  end

  def calculate_total_spent
    start_date = date.beginning_of_month
    end_date = date.end_of_month

    expenses.where(date: start_date..end_date).sum(:amount)
  end
end
