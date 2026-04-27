class HomeController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :redirect_to_login

  TABS = %w[monitoring finance tools].freeze

  def index
    authorize :home

    @active_tab = TABS.include?(params[:tab]) ? params[:tab] : "monitoring"

    load_monitoring_data if @active_tab == "monitoring"
    load_finance_data if @active_tab == "finance"
  end

  def panel
    authorize :home, :panel?

    if params[:crop_id]
      crop = current_user.crops.find(params[:crop_id])
      reminders = Reminder.where(crop: crop).order(:due_on)
      render partial: "crop_panel", locals: { reminders: reminders }
    elsif params[:nursery_id]
      nursery = current_user.nurseries.find(params[:nursery_id])
      render partial: "nursery_panel", locals: { nursery: nursery }
    else
      head :bad_request
    end
  end

  def preset_panel
    authorize :home, :panel?

    if params[:crop_id]
      crop = current_user.crops.includes(:preset).find(params[:crop_id])
      render partial: "preset_panel", locals: { preset: crop.preset }
    elsif params[:nursery_id]
      nursery = current_user.nurseries.includes(:preset).find(params[:nursery_id])
      render partial: "preset_panel", locals: { preset: nursery.preset }
    else
      head :bad_request
    end
  end

  private

  MONITORING_SORT_COLUMNS = %w[name type location status].freeze
  MONITORING_PER_PAGE = 25

  def load_monitoring_data
    @sort_column    = MONITORING_SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "status"
    @sort_direction = params[:direction] == "desc" ? "desc" : "asc"

    nurseries = current_user.nurseries.where(transplanted_on: nil).includes(:preset).to_a
    crops     = current_user.crops.where(harvested_on: nil).includes(:preset).to_a

    rows = build_monitoring_rows(nurseries, crops)
    rows = sort_monitoring_rows(rows, @sort_column, @sort_direction)

    @total_pages  = [ (rows.size.to_f / MONITORING_PER_PAGE).ceil, 1 ].max
    @current_page = [ [ params[:page].to_i, 1 ].max, @total_pages ].min
    offset = (@current_page - 1) * MONITORING_PER_PAGE
    @monitoring_rows = rows[offset, MONITORING_PER_PAGE] || []
  end

  def build_monitoring_rows(nurseries, crops)
    rows = []

    nurseries.each do |nursery|
      days_in  = nursery.started_on ? (Date.today - nursery.started_on).to_i : nil
      max_days = nursery.preset&.days_to_harvest_max
      min_days = nursery.preset&.days_to_harvest_min

      if days_in && max_days
        sv = max_days - days_in
        label_class = days_in > max_days ? "text-red-500" :
                      (min_days && days_in >= min_days ? "text-orange-600" : "text-green-600")
      else
        sv = Float::INFINITY
        label_class = "text-gray-300"
      end

      rows << { type: "nursery", name: nursery.name, location: nil,
                status_text: days_in ? "#{days_in}d in nursery" : "No start date",
                status_class: label_class, status_value: sv, object: nursery }
    end

    crops.each do |crop|
      if crop.expected_harvest_on
        days_left   = (crop.expected_harvest_on - Date.today).to_i
        sv          = days_left
        label_class = days_left < 0  ? "text-red-500"    :
                      days_left == 0 ? "text-orange-600"  :
                      days_left <= 7 ? "text-yellow-600"  :
                      days_left <= 14 ? "text-lime-600"   : "text-green-600"
        status_text = days_left < 0  ? "#{days_left.abs}d overdue" :
                      days_left == 0 ? "Harvest today"              :
                      "#{days_left}d to harvest"
      else
        sv = Float::INFINITY
        label_class = "text-gray-300"
        status_text = "No harvest date"
      end

      rows << { type: "crop", name: crop.name,
                location: crop.location.presence || "Unassigned",
                status_text: status_text, status_class: label_class,
                status_value: sv, object: crop }
    end

    rows
  end

  def sort_monitoring_rows(rows, col, dir)
    rows.sort_by! do |row|
      case col
      when "name"     then row[:name].downcase
      when "type"     then "#{row[:type]}|#{row[:name].downcase}"
      when "location" then "#{row[:location].to_s.downcase}|#{row[:name].downcase}"
      when "status"
        sv = row[:status_value]
        sv == Float::INFINITY ? 999_999 : sv
      else
        row[:name].downcase
      end
    end
    rows.reverse! if dir == "desc"
    if col == "status"
      with_date, without_date = rows.partition { |r| r[:status_value] != Float::INFINITY }
      rows = with_date + without_date
    end
    rows
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
