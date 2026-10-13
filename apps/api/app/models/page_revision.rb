class PageRevision < ApplicationRecord
  STATUSES = %w[draft published archived].freeze

  belongs_to :page
  belongs_to :template_revision
  belongs_to :created_by, class_name: "User"
  has_many :page_blocks, -> { order(:position) }, dependent: :destroy

  validates :title, presence: true
  validates :version, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :page_id }
  validates :status, inclusion: { in: STATUSES }
  validate :published_revision_is_immutable, on: :update

  scope :published, -> { where(status: "published") }

  private

  def published_revision_is_immutable
    errors.add(:base, "published page revisions are immutable") if status_was == "published" && changed?
  end
end
