class PresetCompatibility
  LEVELS = %i[compatible marginal incompatible].freeze

  Result = Struct.new(:level, :reasons, keyword_init: true) do
    def compatible?  = level == :compatible
    def marginal?    = level == :marginal
    def incompatible? = level == :incompatible
  end

  def self.check(preset, user)
    new(preset, user).check
  end

  def initialize(preset, user)
    @cond = preset.growing_conditions
    @user = user
  end

  def check
    return Result.new(level: :unknown, reasons: []) unless @cond.present?
    return Result.new(level: :incomplete_profile, reasons: []) unless profile_complete?

    failures = []
    warnings = []

    check_range(
      label: "Altitude",
      value: @user.altitude_masl,
      min: @cond.dig("altitude_masl", "min"),
      max: @cond.dig("altitude_masl", "max"),
      unit: "masl",
      failures: failures, warnings: warnings
    )

    check_range(
      label: "Temperature",
      value: @user.avg_temp_c,
      min: @cond.dig("temperature_c", "min"),
      max: @cond.dig("temperature_c", "max"),
      optimal_min: @cond.dig("temperature_c", "optimal_min"),
      optimal_max: @cond.dig("temperature_c", "optimal_max"),
      unit: "°C",
      failures: failures, warnings: warnings
    )

    check_range(
      label: "Humidity",
      value: @user.avg_humidity_pct,
      min: @cond.dig("humidity_pct", "min"),
      max: @cond.dig("humidity_pct", "max"),
      unit: "%",
      failures: failures, warnings: warnings
    )

    if failures.any?
      Result.new(level: :incompatible, reasons: failures + warnings)
    elsif warnings.any?
      Result.new(level: :marginal, reasons: warnings)
    else
      Result.new(level: :compatible, reasons: [])
    end
  end

  private

  def profile_complete?
    @user.altitude_masl.present? && @user.avg_temp_c.present? && @user.avg_humidity_pct.present?
  end

  def check_range(label:, value:, min:, max:, unit:, failures:, warnings:, optimal_min: nil, optimal_max: nil)
    return unless value.present? && (min.present? || max.present?)

    v = value.to_f

    if (min && v < min) || (max && v > max)
      range_str = [min, max].compact.join("–")
      failures << "#{label} #{v.to_i}#{unit} is outside the required range (#{range_str}#{unit})"
    elsif optimal_min && optimal_max && (v < optimal_min || v > optimal_max)
      range_str = "#{optimal_min}–#{optimal_max}"
      warnings << "#{label} #{v.to_i}#{unit} is outside the optimal range (#{range_str}#{unit})"
    end
  end
end
