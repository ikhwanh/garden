class Dashboard::ToolsController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :redirect_to_login

  def index
    authorize :home
  end

  private

  def redirect_to_login
    redirect_to new_user_session_path
  end
end
