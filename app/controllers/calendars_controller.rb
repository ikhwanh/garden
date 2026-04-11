class CalendarsController < ApplicationController
  before_action :authenticate_user!

  def show
    calendar = GardenCalendar.new(current_user)

    unless calendar.any_events?
      redirect_to root_path, alert: "No scheduled events to export yet."
      return
    end

    send_data calendar.to_ical, type: "text/calendar", filename: "garden.ics", disposition: "attachment"
  end
end
