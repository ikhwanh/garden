class HomePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def panel?
    user.present?
  end
end
