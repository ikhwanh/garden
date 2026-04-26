class PresetPhase::Fertilization < PresetPhase::Base
  def interval_days = data["interval_days"]
  def to_details = { fertilizers: data["fertilizers"], notes: data["notes"] }
end
