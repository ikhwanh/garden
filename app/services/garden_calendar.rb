class GardenCalendar
  def initialize(user)
    @user = user
  end

  def any_events?
    reminders.exists?
  end

  def to_ical
    cal = Icalendar::Calendar.new
    cal.prodid = "-//Garden//EN"
    cal.publish

    reminders.each do |reminder|
      cal.event do |e|
        e.dtstart     = Icalendar::Values::Date.new(reminder.due_on)
        e.dtend       = Icalendar::Values::Date.new(reminder.due_on)
        e.summary     = "#{reminder.crop.name} – #{reminder.phase.humanize}"
        e.description = format_details(reminder.details)
        e.uid         = "reminder-#{reminder.id}@garden"
      end
    end

    cal.to_ical
  end

  private

  def format_details(details)
    lines = []

    if (actions = details["actions"]).present?
      lines << "Actions:"
      actions.each { |a| lines << "  - #{a}" }
    end

    if (fertilizers = details["fertilizers"]).present?
      lines << "Fertilizers:"
      fertilizers.each do |f|
        parts = [ f["name"], f["dose"] && "#{f["dose"]} #{f["unit"]}" ].compact
        lines << "  - #{parts.join(", ")}"
      end
      lines << "Notes: #{details["notes"]}" if details["notes"].present?
    end

    if (pests = details["pests"]).present?
      lines << "Pests / Diseases:"
      pests.each do |p|
        entry = "  - #{p["name"]}"
        entry += " (every #{p["inspection_interval_days"]}d)" if p["inspection_interval_days"]
        lines << entry
      end
    end

    if (targets = details["targets"]).present?
      lines << "Soil Targets:"
      targets.each do |param, value|
        lines << "  - #{param}: #{value}"
      end
    end

    lines.join("\n")
  end

  def reminders
    @reminders ||= Reminder
      .joins(:crop)
      .where(crops: { user_id: @user.id })
      .includes(:crop)
      .order(:due_on)
  end
end
