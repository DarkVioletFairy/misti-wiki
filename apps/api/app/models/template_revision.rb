class TemplateRevision < ApplicationRecord
  STATUSES = %w[draft published archived].freeze

  belongs_to :template
  belongs_to :created_by, class_name: "User"
  has_many :template_blocks, -> { order(:position) }, dependent: :destroy
  has_many :page_revisions, dependent: :restrict_with_error

  validates :version, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :template_id }
  validates :status, inclusion: { in: STATUSES }
  validate :published_revision_is_immutable, on: :update

  def publish!
    update!(status: "published", published_at: Time.current)
  end

  private

  def published_revision_is_immutable
    errors.add(:base, "published template revisions are immutable") if status_was == "published" && changed?
  end
end
