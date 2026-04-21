class DatabaseController < ApplicationController
  def export
    nurseries = current_user.nurseries.map do |n|
      n.as_json(except: %i[id user_id created_at updated_at])
       .merge("original_id" => n.id)
    end

    crops = current_user.crops.map do |c|
      c.as_json(except: %i[id user_id created_at updated_at nursery_id])
       .merge("original_id" => c.id, "nursery_original_id" => c.nursery_id)
    end

    cashflow_entries = current_user.cashflow_entries
                                   .as_json(except: %i[id user_id created_at updated_at])

    data = {
      exported_at: Time.current.iso8601,
      version: 1,
      nurseries: nurseries,
      crops: crops,
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

    counts = { nurseries: 0, crops: 0, cashflow_entries: 0 }

    ActiveRecord::Base.transaction do
      nursery_map = {}
      (data["nurseries"] || []).each do |n|
        nursery = current_user.nurseries.create!(n.except("original_id"))
        nursery_map[n["original_id"]] = nursery.id if n["original_id"]
        counts[:nurseries] += 1
      end

      (data["crops"] || []).each do |c|
        attrs = c.except("original_id", "nursery_original_id")
                 .merge("nursery_id" => nursery_map[c["nursery_original_id"]])
        current_user.crops.create!(attrs)
        counts[:crops] += 1
      end

      (data["cashflow_entries"] || []).each do |e|
        current_user.cashflow_entries.create!(e)
        counts[:cashflow_entries] += 1
      end
    end

    parts = counts.filter_map { |k, v| "#{v} #{k.to_s.tr('_', ' ')}" if v > 0 }
    redirect_to root_path, notice: "Imported #{parts.join(', ')}."
  rescue => e
    redirect_to root_path, alert: "Import failed: #{e.message}"
  end
end
