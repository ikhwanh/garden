class Reminder < ApplicationRecord
  CATEGORIES = %w[crop_protection pruning_trimming fertilization_schedule pest_disease_checklist soil_parameters].freeze

  belongs_to :plant

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :phase, presence: true
  validates :due_on, presence: true

  scope :pending,    -> { where(notified_at: nil) }
  scope :notified,   -> { where.not(notified_at: nil) }
  scope :due_today,  -> { where(due_on: Date.current) }
  scope :upcoming,   -> { where(notified_at: nil).where("due_on >= ?", Date.current).order(:due_on) }
end
