class Plant < ApplicationRecord
  GROW_MEDIUMS = %w[hydroponic soil].freeze

  belongs_to :user
  belongs_to :seed, optional: true
  has_many :fertilizations, dependent: :destroy
  has_many :harvests, dependent: :destroy

  after_save :update_seed_quantity_final
  after_destroy :update_seed_quantity_final

  def expected_crop_at
    planted_on + days_to_maturity.days if days_to_maturity.present?
  end

  def success_rate
    return nil if quantity_initial.nil? || quantity_final.nil? || quantity_initial.zero?
    (quantity_final.to_f / quantity_initial * 100).round(1)
  end

  validates :name, presence: true
  validates :grow_medium, presence: true, inclusion: { in: GROW_MEDIUMS }
  validates :planted_on, presence: true
  validates :quantity_initial, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :quantity_final, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  private

  def update_seed_quantity_final
    ids = [ seed_id ]
    ids << seed_id_before_last_save if respond_to?(:saved_change_to_seed_id?) && saved_change_to_seed_id?
    ids.compact.uniq.each do |sid|
      s = Seed.find_by(id: sid)
      next unless s
      total = s.plants.sum(:quantity_initial)
      s.update_column(:quantity_final, total.positive? ? total : nil)
    end
  end
end
