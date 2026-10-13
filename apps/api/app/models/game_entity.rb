class GameEntity < ApplicationRecord
  validates :entity_type, :source_id, :slug, presence: true
  validates :source_id, uniqueness: { scope: :entity_type }
  validates :slug, uniqueness: { scope: :entity_type }
  validate :source_data_is_an_object

  scope :publicly_visible, -> {
    where(publicly_available: true).where("released_at IS NULL OR released_at <= ?", Time.current)
  }

  private

  def source_data_is_an_object
    errors.add(:source_data, "must be an object") unless source_data.is_a?(Hash)
  end
end
