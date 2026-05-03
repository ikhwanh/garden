class HomePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def panel?
    user.present?
  end

  def seed_presets?
    user.present?
  end
end
