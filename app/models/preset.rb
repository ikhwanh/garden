class Preset < ApplicationRecord
  GROW_TYPES = %w[soil hydroponic nursery].freeze

  has_many :crops
  has_many :nurseries

  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :grow_type, presence: true, inclusion: { in: GROW_TYPES }
  def nursery?
    grow_type == "nursery"
  end
end
