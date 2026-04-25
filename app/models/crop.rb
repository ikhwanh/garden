class Crop < ApplicationRecord
  belongs_to :user
  belongs_to :nursery, optional: true
  belongs_to :preset, optional: true
  has_many :reminders, dependent: :destroy

  after_save :update_nursery_quantity_final
  after_destroy :update_nursery_quantity_final
  after_destroy :clear_nursery_transplanted_on

  def location
    notes&.match(/^LOCATION:\s*(.+)/i)&.captures&.first&.strip
  end

  def success_rate
    return nil if quantity_initial.nil? || quantity_final.nil? || quantity_initial.zero?
    (quantity_final.to_f / quantity_initial * 100).round(1)
  end

  validates :name, presence: true
  validates :planted_on, presence: true
  validates :quantity_initial, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :quantity_final, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  private

  def clear_nursery_transplanted_on
    nursery&.update_column(:transplanted_on, nil)
  end

  def update_nursery_quantity_final
    ids = [ nursery_id ]
    ids << nursery_id_before_last_save if respond_to?(:saved_change_to_nursery_id?) && saved_change_to_nursery_id?
    ids.compact.uniq.each do |nid|
      n = Nursery.find_by(id: nid)
      next unless n
      total = n.crops.sum(:quantity_initial)
      n.update_column(:quantity_final, total.positive? ? total : nil)
    end
  end
end
