class TemplateBlock < ApplicationRecord
  include GuideBlockTypes

  belongs_to :template_revision

  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, uniqueness: { scope: :template_revision_id }
  validates :block_type, inclusion: { in: ALL }
  validate :validate_block_configuration
  validate :template_revision_is_editable
  before_destroy :ensure_template_revision_is_editable

  private

  def template_revision_is_editable
    errors.add(:base, "published template revisions are immutable") if template_revision&.status == "published"
  end

  def ensure_template_revision_is_editable
    throw(:abort) if template_revision&.status == "published"
  end
end
