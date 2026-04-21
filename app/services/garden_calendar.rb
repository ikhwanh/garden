class GardenCalendar
  def initialize(user)
    @user = user
  end

  def any_events?
    false
  end

  def to_ical
    cal = Icalendar::Calendar.new
    cal.prodid = "-//Garden//EN"
    cal.publish
    cal.to_ical
  end
end
