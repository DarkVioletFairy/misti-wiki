class Template < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  has_many :template_revisions, dependent: :destroy
  has_many :pages, dependent: :restrict_with_error

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }

  def next_revision_version
    template_revisions.maximum(:version).to_i + 1
  end
end
