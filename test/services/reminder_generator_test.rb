require "test_helper"

class ReminderGeneratorTest < ActiveSupport::TestCase
  SOIL_CATEGORIES  = %w[crop_protection fertilization_schedule growth_benchmarks pest_disease_checklist pruning_trimming soil_parameters].freeze
  HYDRO_CATEGORIES = %w[crop_protection growth_benchmarks pest_disease_checklist pruning_trimming].freeze

  setup do
    @user       = users(:one)
    @planted_on = Date.new(2026, 1, 1)

    crops_json     = JSON.parse(File.read(Rails.root.join("app/presets/preset_crops.json")))
    nurseries_json = JSON.parse(File.read(Rails.root.join("app/presets/preset_nurseries.json")))

    @crops_data     = crops_json["crops"].index_by { |c| c["id"] }
    @nurseries_data = nurseries_json["nurseries"].index_by { |n| n["id"] }
  end

  # ── helpers ──────────────────────────────────────────────────────────────────

  def crop_preset(id)
    d = @crops_data.fetch(id)
    Preset.create!(
      slug:                "t-#{id}-#{d["grow_type"]}",
      name:                d["name"],
      grow_type:           d["grow_type"],
      days_to_harvest_min: d.dig("days_to_harvest", "min"),
      days_to_harvest_max: d.dig("days_to_harvest", "max"),
      preset_data:         d["presets"]
    )
  end

  def nursery_preset(id)
    d = @nurseries_data.fetch(id)
    Preset.create!(
      slug:                "t-#{id}-nursery",
      name:                d["name"],
      grow_type:           "nursery",
      days_to_harvest_min: d.dig("days_in_nursery", "min"),
      days_to_harvest_max: d.dig("days_in_nursery", "max"),
      preset_data:         d["presets"]
    )
  end

  def generate(preset, planted_on: @planted_on)
    crop = @user.crops.create!(name: "Test #{preset.slug}", planted_on: planted_on, preset: preset)
    ReminderGenerator.call(crop, preset)
    Reminder.where(crop_id: crop.id)
  end

  def assert_categories(reminders, expected)
    assert_equal expected.sort, reminders.pluck(:category).uniq.sort,
      "Expected categories #{expected.sort.inspect}"
  end

  def assert_reminder_on(reminders, category:, date:)
    assert reminders.exists?(category: category, due_on: date),
      "Expected #{category} reminder on #{date}. Got: #{reminders.where(category: category).pluck(:due_on).sort.inspect}"
  end

  def assert_no_reminder_before(reminders, date)
    early = reminders.where("due_on < ?", date)
    assert early.none?, "Unexpected reminders before #{date}: #{early.pluck(:due_on).inspect}"
  end

  # ── crop presets ─────────────────────────────────────────────────────────────

  test "shallot generates 53 soil reminders" do
    preset    = crop_preset("shallot")
    reminders = generate(preset)

    assert_equal 53, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    # basal fertilizer fires on planted_on
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    # early vegetative fertilizer fires at DAP 7 and 14
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 7.days
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 14.days
    # growth benchmarks at their defined DAPs
    assert_reminder_on reminders, category: "growth_benchmarks", date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks", date: @planted_on + 30.days
    assert_reminder_on reminders, category: "growth_benchmarks", date: @planted_on + 50.days
    # pest inspection interval (min=3 days) fires at DAP 3
    assert_reminder_on reminders, category: "pest_disease_checklist", date: @planted_on + 3.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "shallot_tss generates 41 soil reminders with transplant-relative DAP" do
    preset    = crop_preset("shallot_tss")
    reminders = generate(preset)

    assert_equal 41, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 15.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 40.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 60.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "garlic generates 66 soil reminders" do
    preset    = crop_preset("garlic")
    reminders = generate(preset)

    assert_equal 66, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 21.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 60.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 100.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "celery generates 49 soil reminders with transplant-relative DAP" do
    preset    = crop_preset("celery")
    reminders = generate(preset)

    assert_equal 49, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "crop_protection",        date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 9.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 39.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 69.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "sweet_potato generates 44 soil reminders" do
    preset    = crop_preset("sweet_potato")
    reminders = generate(preset)

    assert_equal 44, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 21.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 60.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 100.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "spring_onion generates 47 soil reminders" do
    preset    = crop_preset("spring_onion")
    reminders = generate(preset)

    assert_equal 47, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 35.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 55.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "chili generates 84 soil reminders with transplant-relative DAP" do
    preset    = crop_preset("chili")
    reminders = generate(preset)

    assert_equal 84, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    # flowering fertilizer fires at DAP 35
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 35.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 20.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 55.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "tomato generates 54 soil reminders with transplant-relative DAP" do
    preset    = crop_preset("tomato")
    reminders = generate(preset)

    assert_equal 54, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 24.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 49.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "spinach generates 35 soil reminders" do
    preset    = crop_preset("spinach")
    reminders = generate(preset)

    assert_equal 35, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 10.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 25.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "kangkung generates 24 soil reminders" do
    preset    = crop_preset("kangkung")
    reminders = generate(preset)

    assert_equal 24, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 28.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "kangkung_hydroponic generates 17 reminders and skips solution_parameters and nutrient_schedule" do
    preset    = crop_preset("kangkung_hydroponic")
    reminders = generate(preset)

    assert_equal 17, reminders.count
    assert_categories reminders, HYDRO_CATEGORIES
    assert_reminder_on reminders, category: "growth_benchmarks", date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks", date: @planted_on + 24.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "lettuce generates 30 soil reminders" do
    preset    = crop_preset("lettuce")
    reminders = generate(preset)

    assert_equal 30, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 35.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "lettuce_hydroponic generates 28 reminders and skips solution_parameters and nutrient_schedule" do
    preset    = crop_preset("lettuce_hydroponic")
    reminders = generate(preset)

    assert_equal 28, reminders.count
    assert_categories reminders, HYDRO_CATEGORIES
    assert_reminder_on reminders, category: "growth_benchmarks", date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks", date: @planted_on + 30.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "pakcoy generates 29 soil reminders" do
    preset    = crop_preset("pakcoy")
    reminders = generate(preset)

    assert_equal 29, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 35.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "pakcoy_hydroponic generates 25 reminders and skips solution_parameters and nutrient_schedule" do
    preset    = crop_preset("pakcoy_hydroponic")
    reminders = generate(preset)

    assert_equal 25, reminders.count
    assert_categories reminders, HYDRO_CATEGORIES
    assert_reminder_on reminders, category: "growth_benchmarks", date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks", date: @planted_on + 30.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "cucumber generates 46 soil reminders" do
    preset    = crop_preset("cucumber")
    reminders = generate(preset)

    assert_equal 46, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 30.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 50.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "eggplant generates 56 soil reminders with transplant-relative DAP" do
    preset    = crop_preset("eggplant")
    reminders = generate(preset)

    assert_equal 56, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 25.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 55.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "long_bean generates 43 soil reminders" do
    preset    = crop_preset("long_bean")
    reminders = generate(preset)

    assert_equal 43, reminders.count
    assert_categories reminders, SOIL_CATEGORIES
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 14.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 35.days
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 55.days
    assert_no_reminder_before reminders, @planted_on
  end

  # ── nursery presets ───────────────────────────────────────────────────────────

  test "shallot_tss nursery generates 20 reminders" do
    preset    = nursery_preset("shallot_tss")
    reminders = generate(preset)

    assert_equal 20, reminders.count
    assert_categories reminders, %w[crop_protection fertilization_schedule growth_benchmarks pest_disease_checklist]
    # nursery fertilizer fires on planted_on (DAP 0) with 7-day interval
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 7.days
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 14.days
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 21.days
    # growth benchmark at end of nursery (DAP 20)
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 20.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "celery nursery generates 12 reminders" do
    preset    = nursery_preset("celery")
    reminders = generate(preset)

    assert_equal 12, reminders.count
    assert_categories reminders, %w[crop_protection pest_disease_checklist]
    assert_reminder_on reminders, category: "crop_protection",        date: @planted_on
    # damping-off inspected every 2 days
    assert_reminder_on reminders, category: "pest_disease_checklist", date: @planted_on + 2.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "chili nursery generates 16 reminders" do
    preset    = nursery_preset("chili")
    reminders = generate(preset)

    assert_equal 16, reminders.count
    assert_categories reminders, %w[crop_protection growth_benchmarks pest_disease_checklist]
    assert_reminder_on reminders, category: "crop_protection",        date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 21.days
    # thrips inspected every 3 days (min of 2 and 3)
    assert_reminder_on reminders, category: "pest_disease_checklist", date: @planted_on + 2.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "tomato nursery generates 14 reminders" do
    preset    = nursery_preset("tomato")
    reminders = generate(preset)

    assert_equal 14, reminders.count
    assert_categories reminders, %w[crop_protection growth_benchmarks pest_disease_checklist]
    assert_reminder_on reminders, category: "crop_protection",        date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 21.days
    # damping-off every 2 days (min of 2 and 3)
    assert_reminder_on reminders, category: "pest_disease_checklist", date: @planted_on + 2.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "eggplant nursery generates 16 reminders" do
    preset    = nursery_preset("eggplant")
    reminders = generate(preset)

    assert_equal 16, reminders.count
    assert_categories reminders, %w[crop_protection growth_benchmarks pest_disease_checklist]
    assert_reminder_on reminders, category: "crop_protection",        date: @planted_on
    assert_reminder_on reminders, category: "growth_benchmarks",      date: @planted_on + 25.days
    # damping-off every 2 days (min of 2 and 3)
    assert_reminder_on reminders, category: "pest_disease_checklist", date: @planted_on + 2.days
    assert_no_reminder_before reminders, @planted_on
  end

  # ── cross-cutting behavior ─────────────────────────────────────────────────────

  test "re-running clears and regenerates the same reminders" do
    preset = crop_preset("shallot")
    crop   = @user.crops.create!(name: "Idempotency test", planted_on: @planted_on, preset: preset)

    ReminderGenerator.call(crop, preset)
    first_count = Reminder.where(crop_id: crop.id).count

    ReminderGenerator.call(crop, preset)
    assert_equal first_count, Reminder.where(crop_id: crop.id).count
  end

  test "all crop preset reminders stay within planted_on..days_to_harvest_max" do
    @crops_data.each do |id, data|
      preset = Preset.create!(
        slug:                "bound-#{id}-#{data["grow_type"]}",
        name:                data["name"],
        grow_type:           data["grow_type"],
        days_to_harvest_min: data.dig("days_to_harvest", "min"),
        days_to_harvest_max: data.dig("days_to_harvest", "max"),
        preset_data:         data["presets"]
      )
      crop    = @user.crops.create!(name: "Bound #{id}", planted_on: @planted_on, preset: preset)
      latest  = @planted_on + preset.days_to_harvest_max.days
      ReminderGenerator.call(crop, preset)

      Reminder.where(crop_id: crop.id).each do |r|
        assert r.due_on >= @planted_on,
          "#{id}: #{r.category}/#{r.phase} due #{r.due_on} is before planted_on"
        assert r.due_on <= latest,
          "#{id}: #{r.category}/#{r.phase} due #{r.due_on} exceeds DAP+#{preset.days_to_harvest_max}"
      end
    end
  end

  test "all nursery preset reminders stay within started_on..days_in_nursery_max" do
    @nurseries_data.each do |id, data|
      preset = Preset.create!(
        slug:                "bound-#{id}-nursery",
        name:                data["name"],
        grow_type:           "nursery",
        days_to_harvest_min: data.dig("days_in_nursery", "min"),
        days_to_harvest_max: data.dig("days_in_nursery", "max"),
        preset_data:         data["presets"]
      )
      crop   = @user.crops.create!(name: "Bound nursery #{id}", planted_on: @planted_on, preset: preset)
      latest = @planted_on + preset.days_to_harvest_max.days
      ReminderGenerator.call(crop, preset)

      Reminder.where(crop_id: crop.id).each do |r|
        assert r.due_on >= @planted_on,
          "#{id}-nursery: #{r.category}/#{r.phase} due #{r.due_on} is before started_on"
        assert r.due_on <= latest,
          "#{id}-nursery: #{r.category}/#{r.phase} due #{r.due_on} exceeds DAS+#{preset.days_to_harvest_max}"
      end
    end
  end
end
