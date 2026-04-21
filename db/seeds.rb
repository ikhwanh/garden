json_path = Rails.root.join("app/presets/preset_crops.json")
data = JSON.parse(File.read(json_path))

data["crops"].each do |crop|
  slug = "#{crop["id"]}-#{crop["grow_type"]}"

  Preset.find_or_initialize_by(slug: slug).tap do |preset|
    preset.name               = crop["name"]
    preset.local_name         = crop["local_name"]
    preset.grow_type          = crop["grow_type"]
    preset.days_to_harvest_min = crop.dig("days_to_harvest", "min")
    preset.days_to_harvest_max = crop.dig("days_to_harvest", "max")
    preset.preset_data        = crop["presets"]
    preset.save!
  end
end

puts "Seeded #{Preset.count} presets"
