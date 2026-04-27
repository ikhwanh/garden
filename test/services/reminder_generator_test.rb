require "test_helper"

class ReminderGeneratorTest < ActiveSupport::TestCase
  FERT_ONLY = %w[fertilization_schedule].freeze

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

  test "shallot generates 10 fertilization reminders" do
    preset    = crop_preset("shallot")
    reminders = generate(preset)

    assert_equal 10, reminders.count
    assert_categories reminders, FERT_ONLY
    # basal fertilizer fires on planted_on
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    # early vegetative fertilizer fires at DAP 7 and 14
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 7.days
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 14.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "shallot_tss generates 10 fertilization reminders with transplant-relative DAP" do
    preset    = crop_preset("shallot_tss")
    reminders = generate(preset)

    assert_equal 10, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "garlic generates 16 fertilization reminders" do
    preset    = crop_preset("garlic")
    reminders = generate(preset)

    assert_equal 16, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "celery generates 7 fertilization reminders with transplant-relative DAP" do
    preset    = crop_preset("celery")
    reminders = generate(preset)

    assert_equal 7, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "sweet_potato generates 3 fertilization reminders" do
    preset    = crop_preset("sweet_potato")
    reminders = generate(preset)

    assert_equal 3, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "spring_onion generates 8 fertilization reminders" do
    preset    = crop_preset("spring_onion")
    reminders = generate(preset)

    assert_equal 8, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "chili generates 32 fertilization reminders with transplant-relative DAP" do
    preset    = crop_preset("chili")
    reminders = generate(preset)

    assert_equal 32, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    # flowering fertilizer fires at DAP 35
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 35.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "tomato generates 18 fertilization reminders with transplant-relative DAP" do
    preset    = crop_preset("tomato")
    reminders = generate(preset)

    assert_equal 18, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "spinach generates 4 fertilization reminders" do
    preset    = crop_preset("spinach")
    reminders = generate(preset)

    assert_equal 4, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "kangkung generates 4 fertilization reminders" do
    preset    = crop_preset("kangkung")
    reminders = generate(preset)

    assert_equal 4, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "kangkung_hydroponic generates 0 reminders" do
    preset    = crop_preset("kangkung_hydroponic")
    reminders = generate(preset)

    assert_equal 0, reminders.count
  end

  test "lettuce generates 4 fertilization reminders" do
    preset    = crop_preset("lettuce")
    reminders = generate(preset)

    assert_equal 4, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "lettuce_hydroponic generates 0 reminders" do
    preset    = crop_preset("lettuce_hydroponic")
    reminders = generate(preset)

    assert_equal 0, reminders.count
  end

  test "pakcoy generates 4 fertilization reminders" do
    preset    = crop_preset("pakcoy")
    reminders = generate(preset)

    assert_equal 4, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "pakcoy_hydroponic generates 0 reminders" do
    preset    = crop_preset("pakcoy_hydroponic")
    reminders = generate(preset)

    assert_equal 0, reminders.count
  end

  test "cucumber generates 10 fertilization reminders" do
    preset    = crop_preset("cucumber")
    reminders = generate(preset)

    assert_equal 10, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "eggplant generates 17 fertilization reminders with transplant-relative DAP" do
    preset    = crop_preset("eggplant")
    reminders = generate(preset)

    assert_equal 17, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  test "long_bean generates 7 fertilization reminders" do
    preset    = crop_preset("long_bean")
    reminders = generate(preset)

    assert_equal 7, reminders.count
    assert_categories reminders, FERT_ONLY
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_no_reminder_before reminders, @planted_on
  end

  # ── nursery presets ───────────────────────────────────────────────────────────

  test "shallot_tss nursery generates 4 fertilization reminders" do
    preset    = nursery_preset("shallot_tss")
    reminders = generate(preset)

    assert_equal 4, reminders.count
    assert_categories reminders, FERT_ONLY
    # nursery fertilizer fires on planted_on (DAP 0) with 7-day interval
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 7.days
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 14.days
    assert_reminder_on reminders, category: "fertilization_schedule", date: @planted_on + 21.days
    assert_no_reminder_before reminders, @planted_on
  end

  test "celery nursery generates 0 reminders" do
    preset    = nursery_preset("celery")
    reminders = generate(preset)

    assert_equal 0, reminders.count
  end

  test "chili nursery generates 0 reminders" do
    preset    = nursery_preset("chili")
    reminders = generate(preset)

    assert_equal 0, reminders.count
  end

  test "tomato nursery generates 0 reminders" do
    preset    = nursery_preset("tomato")
    reminders = generate(preset)

    assert_equal 0, reminders.count
  end

  test "eggplant nursery generates 0 reminders" do
    preset    = nursery_preset("eggplant")
    reminders = generate(preset)

    assert_equal 0, reminders.count
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
