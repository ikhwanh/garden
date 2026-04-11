class Seed < ApplicationRecord
  belongs_to :user
  has_many :plants, dependent: :destroy

  def end_at
    return nil if started_at.nil? || germination_days.nil?
    started_at + germination_days.days
  end

  validates :name, presence: true
  validates :germination_days, numericality: { greater_than: 0 }, allow_nil: true
  validates :transplanted_at, comparison: { less_than_or_equal_to: -> { Date.today } }, allow_nil: true
end
