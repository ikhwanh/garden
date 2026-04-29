class FertilizationCalendarController < ApplicationController
  before_action :authenticate_user!

  def index
    @year  = params[:year]&.to_i  || Date.today.year
    @month = params[:month]&.to_i || Date.today.month
    @date  = Date.new(@year, @month, 1)

    builder = FertilizationScheduleBuilder.new(current_user)
    @events = builder.events_for_month(@year, @month)
  end

  def day
    @date    = Date.parse(params[:date])
    builder  = FertilizationScheduleBuilder.new(current_user)
    @entries = builder.events_for_month(@date.year, @date.month).fetch(@date, [])
    render partial: "day_panel", locals: { date: @date, entries: @entries }, layout: false
  end

  def export
    builder    = FertilizationScheduleBuilder.new(current_user)
    all_events = builder.all_events

    if all_events.empty?
      redirect_to fertilization_calendar_path, alert: "No fertilization schedule to export."
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
