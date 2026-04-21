class PresetPhase::Pest < PresetPhase::Base
  def interval_days
    data["pests"]&.map { |p| p["inspection_interval_days"] }&.min
  end

  def to_details = { pests: data["pests"] }
end
