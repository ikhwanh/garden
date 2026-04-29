class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def after_sign_in_path_for(_resource)
    dashboard_monitoring_path
  end

  def after_sign_up_path_for(_resource)
    dashboard_monitoring_path
  end
end
