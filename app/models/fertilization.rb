class Fertilization < ApplicationRecord
  FERTILIZER_TYPES = %w[NPK AB_Mix Urea KCL].freeze

  belongs_to :plant

  validates :fertilizer_type, presence: true, inclusion: { in: FERTILIZER_TYPES }
  validates :applied_on, presence: true
  validates :amount, numericality: { greater_than: 0 }, allow_nil: true
end
