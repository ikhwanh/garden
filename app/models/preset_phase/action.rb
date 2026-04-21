class PresetPhase::Action < PresetPhase::Base
  def to_details = { actions: data["actions"] }
end
