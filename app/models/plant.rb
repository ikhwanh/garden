class Plant < ApplicationRecord
  GROW_MEDIUMS = %w[hydroponic soil].freeze

  belongs_to :user
  belongs_to :seed
  has_many :fertilizations, dependent: :destroy
  has_many :harvests, dependent: :destroy

  validates :name, presence: true
  validates :grow_medium, presence: true, inclusion: { in: GROW_MEDIUMS }
  validates :planted_on, presence: true
end
