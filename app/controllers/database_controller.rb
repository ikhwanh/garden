class DatabaseController < ApplicationController
  def export
    plant_ids = current_user.plants.pluck(:id)

    seeds = current_user.seeds.map do |s|
      s.as_json(except: %i[id user_id created_at updated_at])
       .merge("original_id" => s.id)
    end

    plants = current_user.plants.map do |p|
      p.as_json(except: %i[id user_id created_at updated_at seed_id])
       .merge("original_id" => p.id, "seed_original_id" => p.seed_id)
    end

    cashflow_entries = current_user.cashflow_entries
                                   .as_json(except: %i[id user_id created_at updated_at])

    data = {
      exported_at: Time.current.iso8601,
      version: 1,
      seeds: seeds,
      plants: plants,
      cashflow_entries: cashflow_entries
    }

    send_data data.to_json,
              filename: "garden-export-#{Date.today}.json",
              type: "application/json",
              disposition: "attachment"
  end

  def import
    file = params[:file]
    return redirect_to root_path, alert: "No file selected." unless file

    begin
      data = JSON.parse(file.read)
    rescue JSON::ParserError
      return redirect_to root_path, alert: "Invalid JSON file."
    end

    counts = { seeds: 0, plants: 0, cashflow_entries: 0 }

    ActiveRecord::Base.transaction do
      seed_map = {}
      (data["seeds"] || []).each do |s|
        seed = current_user.seeds.create!(s.except("original_id"))
        seed_map[s["original_id"]] = seed.id if s["original_id"]
        counts[:seeds] += 1
      end

      plant_map = {}
      (data["plants"] || []).each do |p|
        attrs = p.except("original_id", "seed_original_id")
                 .merge("seed_id" => seed_map[p["seed_original_id"]])
        plant = current_user.plants.create!(attrs)
        plant_map[p["original_id"]] = plant.id if p["original_id"]
        counts[:plants] += 1
      end

      (data["cashflow_entries"] || []).each do |c|
        current_user.cashflow_entries.create!(c)
        counts[:cashflow_entries] += 1
      end
    end

    parts = counts.filter_map { |k, v| "#{v} #{k.to_s.tr('_', ' ')}" if v > 0 }
    redirect_to root_path, notice: "Imported #{parts.join(', ')}."
  rescue => e
    redirect_to root_path, alert: "Import failed: #{e.message}"
  end
end
