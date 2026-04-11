class Plant < ApplicationRecord
  GROW_MEDIUMS = %w[hydroponic soil].freeze

  belongs_to :user
  belongs_to :seed, optional: true
  has_many :fertilizations, dependent: :destroy
  has_many :harvests, dependent: :destroy

  def expected_crop_at
    planted_on + days_to_maturity.days if days_to_maturity.present?
  end

  validates :name, presence: true
  validates :grow_medium, presence: true, inclusion: { in: GROW_MEDIUMS }
  validates :planted_on, presence: true
end
