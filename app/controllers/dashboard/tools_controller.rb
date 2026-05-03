class Dashboard::ToolsController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :redirect_to_login

  def index
    authorize :home
  end

  def seed_presets
    authorize :home

    load Rails.root.join("db/seeds.rb")
    redirect_to dashboard_tools_path, notice: "Presets seeded successfully (#{Preset.count} total)."
  end

  private

  def redirect_to_login
    redirect_to new_user_session_path
  end
end
