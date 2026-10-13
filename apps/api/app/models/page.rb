class Page < ApplicationRecord
  STATUSES = %w[draft published archived].freeze

  belongs_to :template
  belongs_to :created_by, class_name: "User"
  belongs_to :published_revision, class_name: "PageRevision", optional: true
  has_many :page_revisions, dependent: :destroy

  validates :slug, :locale, presence: true
  validates :slug, uniqueness: { scope: :locale }, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }
  validates :status, inclusion: { in: STATUSES }
  validate :published_revision_belongs_to_page

  scope :publicly_visible, -> {
    where(status: "published").where.not(published_revision_id: nil)
      .joins(:published_revision).merge(PageRevision.published)
  }

  def next_revision_version
    page_revisions.maximum(:version).to_i + 1
  end

  def publish!(revision:)
    raise ArgumentError, "revision does not belong to this page" unless revision.page_id == id

    transaction do
      published_at = Time.current
      revision.update!(status: "published", published_at: published_at)
      update!(status: "published", published_revision: revision, published_at: published_at)
    end
  end

  def unpublish!
    update!(status: "draft")
  end

  private

  def published_revision_belongs_to_page
    return if published_revision.blank? || published_revision.page_id == id

    errors.add(:published_revision, "must belong to the page")
  end
end
