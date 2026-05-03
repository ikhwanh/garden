class PresetPhase::GrowthBenchmark < PresetPhase::Base
  def phase_name    = "DAP #{data["dap"]}"
  def dap_min       = 0
  def dap_max       = context[:days_max] || data["dap"].to_i
  def interval_days = data["dap"].to_i
  def to_details    = { targets: data["targets"], notes: data["notes"] }
end
