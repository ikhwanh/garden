class ReminderGenerator
  def self.call(plant, preset)
    new(plant, preset).call
  end

  def initialize(plant, preset)
    @plant  = plant
    @preset = preset
  end

  def call
    reminders = []

    @preset.preset_data.each do |category, phases|
      next unless PresetPhase::Base::CATEGORY_MAP.key?(category)
      phases.each do |phase_data|
        phase = PresetPhase::Base.for(category, phase_data)

        due_dates_for(phase).each do |due_on|
          reminders << {
            crop_id:    @plant.id,
            category:   category,
            phase:      phase.phase_name,
            due_on:     due_on,
            details:    phase.to_details,
            created_at: Time.current,
            updated_at: Time.current
          }
        end
      end
    end

    Reminder.where(crop_id: @plant.id).delete_all
    Reminder.insert_all(reminders) if reminders.any?
  end

  private

  def due_dates_for(phase)
    base = @plant.planted_on
    interval = phase.interval_days

    return [ base + phase.dap_min.days ] unless interval

    dates = []
    dap = phase.dap_min
    while dap <= phase.dap_max
      dates << base + dap.days
      dap += interval
    end
    dates
  end
end
