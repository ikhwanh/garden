class PresetPhase::SoilParameter < PresetPhase::Base
  def to_details = { targets: data["targets"] }
end
