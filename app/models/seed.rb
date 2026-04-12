class Seed < ApplicationRecord
  belongs_to :user
  has_many :plants, dependent: :destroy

  def expected_germination_on
    return nil if started_on.nil? || germination_days.nil?
    started_on + germination_days.days
  end

  def success_rate
    return nil if quantity_initial.nil? || quantity_final.nil? || quantity_initial.zero?
    (quantity_final.to_f / quantity_initial * 100).round(1)
  end

  validates :name, presence: true
  validates :germination_days, numericality: { greater_than: 0 }, allow_nil: true
  validates :transplanted_on, comparison: { less_than_or_equal_to: -> { Date.today } }, allow_nil: true
  validates :quantity_initial, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :quantity_final, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
end
