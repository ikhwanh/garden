class CashflowController < ApplicationController
  before_action :authenticate_user!

  def index
    @start_date = parse_date(params[:start_date]) || 12.months.ago.beginning_of_month.to_date
    @end_date   = parse_date(params[:end_date])   || Date.today.end_of_month

    @entries = current_user.cashflow_entries
                           .between(@start_date, @end_date)
                           .ordered

    @entry = current_user.cashflow_entries.new
  end

  private

  def parse_date(val)
    Date.parse(val) if val.present?
  rescue Date::Error
    nil
  end
end
