class Harvest < ApplicationRecord
  belongs_to :plant

  after_save :update_plant_quantity_final
  after_destroy :update_plant_quantity_final

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

  def update_plant_quantity_final
    total = plant.harvests.sum(:quantity)
    plant.update_column(:quantity_final, total.positive? ? total : nil)
  end
end
