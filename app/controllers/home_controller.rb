class HomeController < ApplicationController
  def index
    return unless user_signed_in?

    @cf_start_date = parse_date(params[:cf_start]) || 12.months.ago.beginning_of_month.to_date
    @cf_end_date   = parse_date(params[:cf_end])   || Date.today.end_of_month

    entries = current_user.cashflow_entries
                          .between(@cf_start_date, @cf_end_date)
                          .chronological

    @cf_total_income   = entries.select { |e| e.entry_type == "income" }.sum(&:amount)
    @cf_total_expenses = entries.select { |e| e.entry_type == "expense" }.sum(&:amount)
    @cf_net            = @cf_total_income - @cf_total_expenses

    @cf_chart_labels   = []
    @cf_chart_income   = []
    @cf_chart_expenses = []

    monthly = entries.group_by { |e| e.occurred_on.beginning_of_month }
    current = @cf_start_date.beginning_of_month
    cum_income = 0
    cum_expense = 0

    while current <= @cf_end_date.beginning_of_month
      month_entries = monthly[current] || []
      cum_income  += month_entries.select { |e| e.entry_type == "income" }.sum(&:amount)
      cum_expense += month_entries.select { |e| e.entry_type == "expense" }.sum(&:amount)

      @cf_chart_labels   << current.strftime("%b %Y")
      @cf_chart_income   << cum_income
      @cf_chart_expenses << cum_expense

      current = current.next_month
    end
  end

  private

  def parse_date(val)
    Date.parse(val) if val.present?
  rescue Date::Error
    nil
  end
end
