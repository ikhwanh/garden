class Preset < ApplicationRecord
  GROW_TYPES = %w[soil hydroponic].freeze

  has_many :plants

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :grow_type, presence: true, inclusion: { in: GROW_TYPES }
end
