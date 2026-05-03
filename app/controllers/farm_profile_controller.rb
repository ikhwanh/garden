class FarmProfileController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update(farm_profile_params)
      redirect_to edit_user_registration_path, notice: "Farm profile saved."
    else
      redirect_to edit_user_registration_path, alert: "Could not save farm profile."
    end
  end

  private

  def farm_profile_params
    params.require(:user).permit(:altitude_masl, :avg_temp_c, :avg_humidity_pct)
  end
end
