class PresetPhase::Base
  CATEGORY_MAP = {
    "crop_protection"        => "PresetPhase::Action",
    "pruning_trimming"       => "PresetPhase::Action",
    "fertilization_schedule" => "PresetPhase::Fertilization",
    "pest_disease_checklist" => "PresetPhase::Pest",
    "soil_parameters"        => "PresetPhase::SoilParameter",
    "growth_benchmarks"      => "PresetPhase::GrowthBenchmark"
  }.freeze

  attr_reader :data, :context

  def self.for(category, data, context = {})
    CATEGORY_MAP.fetch(category).constantize.new(data, context)
  end

  def initialize(data, context = {})
    @data    = data
    @context = context
  end

  def phase_name   = data["phase"]
  def dap_min      = data.dig("dap_range", "min").to_i
  def dap_max      = data.dig("dap_range", "max").to_i
  def interval_days = nil

  def to_details
    raise NotImplementedError
  end
end
