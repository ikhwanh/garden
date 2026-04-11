class GardenCalendar
  def initialize(user)
    @user = user
  end

  def any_events?
    @user.plants.where.not(days_to_maturity: nil).exists? ||
      @user.seeds.where.not(started_on: nil, germination_days: nil).exists? ||
      Fertilization.joins(:plant).where(plants: { user: @user }).exists?
  end

  def to_ical
    cal = Icalendar::Calendar.new
    cal.prodid = "-//Garden//EN"

    harvest_events(cal)
    germination_events(cal)
    fertilization_events(cal)

    cal.publish
    cal.to_ical
  end

  private

  def harvest_events(cal)
    @user.plants.where.not(days_to_maturity: nil).each do |plant|
      date = plant.expected_crop_at
      next unless date
      next if date < Date.today

      cal.event do |e|
        e.dtstart = Icalendar::Values::Date.new(date)
        e.dtend   = Icalendar::Values::Date.new(date + 1)
        e.summary = "Harvest: #{plant.name}"
        e.uid     = "plant-#{plant.id}-harvest@garden"
      end
    end
  end

  def germination_events(cal)
    @user.seeds.where.not(started_on: nil, germination_days: nil).each do |seed|
      date = seed.expected_germination_on
      next unless date
      next if date < Date.today

      cal.event do |e|
        e.dtstart = Icalendar::Values::Date.new(date)
        e.dtend   = Icalendar::Values::Date.new(date + 1)
        e.summary = "Germination: #{seed.name}"
        e.uid     = "seed-#{seed.id}-germination@garden"
      end
    end
  end

  def fertilization_events(cal)
    Fertilization.joins(:plant).where(plants: { user: @user }).each do |fert|
      date = fert.applied_on
      next if date < Date.today

      cal.event do |e|
        e.dtstart = Icalendar::Values::Date.new(date)
        e.dtend   = Icalendar::Values::Date.new(date + 1)
        e.summary = "Fertilize #{fert.plant.name}: #{fert.fertilizer_type}"
        e.uid     = "fertilization-#{fert.id}@garden"
      end
    end
  end
end
