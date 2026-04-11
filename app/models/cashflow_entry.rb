class CashflowEntry < ApplicationRecord
  belongs_to :user

  ENTRY_TYPES = %w[income expense].freeze
  COST_TYPES  = %w[fixed variable].freeze

  INCOME_CATEGORIES  = %w[sales grant service].freeze
  EXPENSE_CATEGORIES = %w[tool growing_media seed].freeze

  validates :entry_type, inclusion: { in: ENTRY_TYPES }
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :description, presence: true
  validates :occurred_on, presence: true
  validates :cost_type, inclusion: { in: COST_TYPES }, allow_nil: true
  validates :category,
    inclusion: { in: INCOME_CATEGORIES + EXPENSE_CATEGORIES },
    allow_nil: true

  scope :income, -> { where(entry_type: "income") }
  scope :expense, -> { where(entry_type: "expense") }
  scope :between, ->(start_date, end_date) { where(occurred_on: start_date..end_date) }
  scope :chronological, -> { order(occurred_on: :asc) }
  scope :ordered, -> { order(occurred_on: :desc, created_at: :desc) }
end
