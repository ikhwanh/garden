class HomeController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :redirect_to_login

  TABS = %w[monitoring finance tools].freeze

  def index
    authorize :home

    @active_tab = TABS.include?(params[:tab]) ? params[:tab] : "monitoring"

    load_monitoring_data if @active_tab == "monitoring"
    load_finance_data if @active_tab == "finance"
  end

  private

  def load_monitoring_data
    active_crops = current_user.crops.where(harvested_on: nil).includes(:preset)
    @crops_by_location = active_crops.group_by { |c| c.location.presence || "Unassigned" }
                                     .sort_by { |loc, _| loc == "Unassigned" ? "zzz" : loc.downcase }
                                     .to_h

    @upcoming_reminders = Reminder
      .joins(:crop)
      .where(crops: { user_id: current_user.id })
      .where(due_on: Date.today..30.days.from_now)
      .order(:due_on)
      .includes(:crop)
  end

  def load_finance_data
    @cf_start_date = parse_date(params[:cf_start]) || 12.months.ago.beginning_of_month.to_date
    @cf_end_date   = parse_date(params[:cf_end])   || Date.today.end_of_month
    @cf_cost_type  = params[:cf_cost_type].presence

    entries = current_user.cashflow_entries
                          .between(@cf_start_date, @cf_end_date)
                          .then { |q| @cf_cost_type ? q.where(cost_type: @cf_cost_type) : q }
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

    @nursery_rates = current_user.nurseries
      .where.not(quantity_initial: nil).where.not(quantity_final: nil)
      .where("quantity_initial > 0")
      .order(:name)

    @crop_rates = current_user.crops
      .where.not(quantity_initial: nil).where.not(quantity_final: nil)
      .where("quantity_initial > 0")
      .order(:name)
  end

  def redirect_to_login
    redirect_to new_user_session_path
  end

  def parse_date(val)
    Date.parse(val) if val.present?
  rescue Date::Error
    nil
  end
end
