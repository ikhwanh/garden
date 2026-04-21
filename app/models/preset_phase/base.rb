class PresetPhase::Base
  CATEGORY_MAP = {
    "crop_protection"        => "PresetPhase::Action",
    "pruning_trimming"       => "PresetPhase::Action",
    "fertilization_schedule" => "PresetPhase::Fertilization",
    "pest_disease_checklist" => "PresetPhase::Pest",
    "soil_parameters"        => "PresetPhase::SoilParameter"
  }.freeze

  attr_reader :data

  def self.for(category, data)
    CATEGORY_MAP.fetch(category).constantize.new(data)
  end

  def initialize(data)
    @data = data
  end

  def phase_name   = data["phase"]
  def dap_min      = data.dig("dap_range", "min").to_i
  def dap_max      = data.dig("dap_range", "max").to_i
  def interval_days = nil

  def to_details
    raise NotImplementedError
  end
end
