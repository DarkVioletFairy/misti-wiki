class Role < ApplicationRecord
  PERMISSIONS = {
    "owner" => %i[manage_users manage_templates manage_content publish_content review_imports],
    "editor" => %i[manage_templates manage_content],
    "publisher" => %i[manage_templates manage_content publish_content],
    "reviewer" => %i[review_imports]
  }.freeze

  has_many :users, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def grants?(permission)
    PERMISSIONS.fetch(name, []).include?(permission.to_sym)
  end
end
