class Seed < ApplicationRecord
  belongs_to :user
  has_many :plants, dependent: :destroy

  validates :name, presence: true
  validates :germination_days, numericality: { greater_than: 0 }, allow_nil: true
  validates :transplant_days, numericality: { greater_than: 0 }, allow_nil: true
end
