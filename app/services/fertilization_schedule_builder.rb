class FertilizationScheduleBuilder
  Entry = Data.define(:crop, :phase_name, :fertilizers, :notes)

  def initialize(user)
    @user = user
  end

  def events_for_month(year, month)
    start_date = Date.new(year, month, 1)
    end_date   = start_date.end_of_month
    events_in_range(start_date, end_date)
  end

  def all_events
    events_in_range(nil, nil)
  end

  private

  def events_in_range(start_date, end_date)
    result = Hash.new { |h, k| h[k] = [] }

    crops_with_presets.each do |crop|
      fertilization_phases(crop.preset).each do |phase_data|
        phase = PresetPhase::Fertilization.new(phase_data)
        due_dates_for(crop, phase).each do |date|
          next if start_date && date < start_date
          next if end_date   && date > end_date
          result[date] << Entry.new(
            crop:        crop,
            phase_name:  phase.phase_name,
            fertilizers: Array(phase.to_details[:fertilizers]),
            notes:       phase.to_details[:notes]
          )
        end
      end
    end

    result
  end

  def crops_with_presets
    @crops_with_presets ||= @user.crops
      .includes(:preset)
      .where.not(preset_id: nil)
      .where.not(planted_on: nil)
      .where(harvested_on: nil)
  end

  def fertilization_phases(preset)
    Array(preset.preset_data&.dig("fertilization_schedule"))
  end

  def due_dates_for(crop, phase)
    base     = crop.planted_on
    interval = phase.interval_days

    return [ base + phase.dap_min.days ] unless interval

    dates = []
    dap   = phase.dap_min
    while dap <= phase.dap_max
      dates << base + dap.days
      dap   += interval
    end
    dates
  end
end
