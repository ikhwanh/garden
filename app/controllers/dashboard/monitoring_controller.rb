class Dashboard::MonitoringController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :redirect_to_login

  SORT_COLUMNS = %w[name type location status].freeze
  PER_PAGE = 25

  def index
    authorize :home

    @sort_column    = SORT_COLUMNS.include?(params[:sort]) ? params[:sort] : "status"
    @sort_direction = params[:direction] == "desc" ? "desc" : "asc"

    nurseries = current_user.nurseries.where(transplanted_on: nil).includes(:preset).to_a
    crops     = current_user.crops.where(harvested_on: nil).includes(:preset).to_a

    rows = build_monitoring_rows(nurseries, crops)
    rows = sort_monitoring_rows(rows, @sort_column, @sort_direction)

    @total_pages  = [ (rows.size.to_f / PER_PAGE).ceil, 1 ].max
    @current_page = [ [ params[:page].to_i, 1 ].max, @total_pages ].min
    offset = (@current_page - 1) * PER_PAGE
    @monitoring_rows = rows[offset, PER_PAGE] || []
  end

  def detail_panel
    authorize :home, :panel?

    if params[:crop_id]
      obj  = current_user.crops.includes(:preset).find(params[:crop_id])
      dap  = (Date.today - obj.planted_on).to_i
      kind = "crop"
    elsif params[:nursery_id]
      obj  = current_user.nurseries.includes(:preset).find(params[:nursery_id])
      dap  = obj.started_on ? (Date.today - obj.started_on).to_i : nil
      kind = "nursery"
    else
      head :bad_request and return
    end

    preset = obj.preset
    active_phases, upcoming_phases = phase_split(preset, dap)

    render partial: "detail_panel_#{kind}", locals: {
      obj: obj, dap: dap,
      preset: preset, active_phases: active_phases, upcoming_phases: upcoming_phases
    }
  end

  private

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
        status_text = sv < 0  ? "#{sv.abs}d overdue"    :
                      sv == 0 ? "Transplant today"       :
                      "#{sv}d to transplant"
      else
        sv = Float::INFINITY
        label_class = "text-gray-300"
        status_text = days_in ? "No transplant date" : "No start date"
      end

      rows << { type: "nursery", name: nursery.name, location: nil,
                status_text: status_text,
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

  def phase_split(preset, dap)
    return [ {}, {} ] unless preset&.preset_data.present? && dap

    section_order = %w[crop_protection pruning_trimming fertilization_schedule
                       pest_disease_checklist soil_parameters growth_benchmarks]
    data = preset.preset_data

    active   = {}
    upcoming = {}

    section_order.each do |key|
      phases = data[key]
      next if phases.blank?

      active[key] = phases.find { |p|
        r = p["dap_range"]
        r && dap >= r["min"].to_i && dap <= r["max"].to_i
      }

      upcoming[key] = phases
        .select  { |p| p.dig("dap_range", "min").to_i > dap }
        .min_by  { |p| p.dig("dap_range", "min").to_i }
    end

    active.compact!
    upcoming.compact!

    [ active, upcoming ]
  end

  def redirect_to_login
    redirect_to new_user_session_path
  end
end
