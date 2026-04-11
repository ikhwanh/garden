class Harvest < ApplicationRecord
  belongs_to :plant

  validates :harvested_on, presence: true
  validates :weight_grams, numericality: { greater_than: 0 }, allow_nil: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :weight_or_quantity_present

  private

  def weight_or_quantity_present
    if weight_grams.blank? && quantity.blank?
      errors.add(:base, "must provide either weight or quantity")
    end
  end
end
