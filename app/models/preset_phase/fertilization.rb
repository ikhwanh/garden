class PresetPhase::Fertilization < PresetPhase::Base
  def to_details = { fertilizers: data["fertilizers"], notes: data["notes"] }
end
