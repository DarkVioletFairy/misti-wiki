class PageBlock < ApplicationRecord
  include GuideBlockTypes

  belongs_to :page_revision

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, uniqueness: { scope: :page_revision_id }
  validates :block_type, inclusion: { in: ALL }
  validate :validate_block_configuration
  validate :page_revision_is_editable
  before_destroy :ensure_page_revision_is_editable

  private

  def page_revision_is_editable
    errors.add(:base, "published page revisions are immutable") if page_revision&.status == "published"
  end

  def ensure_page_revision_is_editable
    throw(:abort) if page_revision&.status == "published"
  end
end
