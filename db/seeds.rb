crop_data = JSON.parse(File.read(Rails.root.join("app/presets/preset_crops.json")))

crop_data["crops"].each do |crop|
  slug = "#{crop["id"]}-#{crop["grow_type"]}"

  Preset.find_or_initialize_by(slug: slug).tap do |preset|
    preset.name                = crop["name"]
    preset.local_name          = crop["local_name"]
    preset.grow_type           = crop["grow_type"]
    preset.days_min = crop.dig("days_to_harvest", "min")
    preset.days_max = crop.dig("days_to_harvest", "max")
    preset.preset_data         = crop["presets"]
    preset.save!
  end
end

nursery_data = JSON.parse(File.read(Rails.root.join("app/presets/preset_nurseries.json")))

nursery_data["nurseries"].each do |nursery|
  slug = "#{nursery["id"]}-nursery"

  Preset.find_or_initialize_by(slug: slug).tap do |preset|
    preset.name                = "#{nursery["name"]} (Nursery)"
    preset.local_name          = nursery["local_name"]
    preset.grow_type           = "nursery"
    preset.days_min = nursery.dig("days_in_nursery", "min")
    preset.days_max = nursery.dig("days_in_nursery", "max")
    preset.preset_data         = nursery["presets"]
    preset.save!
  end
end

puts "Seeded #{Preset.count} presets (#{crop_data["crops"].size} crops + #{nursery_data["nurseries"].size} nurseries)"
