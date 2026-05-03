class Dashboard::FertilizationCalendarController < ApplicationController
  before_action :authenticate_user!

  def index
    @year  = params[:year]&.to_i  || Date.today.year
    @month = params[:month]&.to_i || Date.today.month
    @date  = Date.new(@year, @month, 1)

    builder = FertilizationScheduleBuilder.new(current_user)
    @events = builder.events_for_month(@year, @month)

    month_range       = @date..@date.end_of_month
    active_crops      = current_user.crops.where(harvested_on: nil)
    @plant_events     = active_crops.where(planted_on: month_range).group_by(&:planted_on)
    @harvest_events   = active_crops.where(expected_harvest_on: month_range).group_by(&:expected_harvest_on)
  end

  def day
    @date    = Date.parse(params[:date])
    builder  = FertilizationScheduleBuilder.new(current_user)
    @entries = builder.events_for_month(@date.year, @date.month).fetch(@date, [])

    active_crops   = current_user.crops.where(harvested_on: nil)
    planted_crops  = active_crops.where(planted_on: @date)
    harvest_crops  = active_crops.where(expected_harvest_on: @date)

    render partial: "day_panel",
           locals: { date: @date, entries: @entries, planted_crops: planted_crops, harvest_crops: harvest_crops },
           layout: false
  end

  def export
    builder    = FertilizationScheduleBuilder.new(current_user)
    all_events = builder.all_events

    if all_events.empty?
      redirect_to dashboard_fertilization_calendar_path, alert: "No fertilization schedule to export."
      return
    end

    cal = Icalendar::Calendar.new
    cal.prodid = "-//Garden Fertilization//EN"
    cal.publish

    all_events.each do |date, entries|
      entries.each do |entry|
        cal.event do |e|
          e.dtstart     = Icalendar::Values::Date.new(date)
          e.dtend       = Icalendar::Values::Date.new(date)
          e.summary     = "#{entry.crop.name} – #{entry.phase_name&.humanize} Fertilization"
          lines         = []
          lines << "Fertilizers: #{entry.fertilizers.join(", ")}" if entry.fertilizers.any?
          lines << "Notes: #{entry.notes}" if entry.notes.present?
          e.description = lines.join("\n")
          e.uid         = "fert-#{entry.crop.id}-#{date}-#{entry.phase_name}@garden"
        end
      end
    end

    send_data cal.to_ical,
      type:        "text/calendar",
      filename:    "fertilization_schedule.ics",
      disposition: "attachment"
  end
end
