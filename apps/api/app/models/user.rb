class User < ApplicationRecord
  belongs_to :role
  has_many :api_sessions, dependent: :destroy
  has_many :created_templates, class_name: "Template", foreign_key: :created_by_id, dependent: :restrict_with_error
  has_many :created_pages, class_name: "Page", foreign_key: :created_by_id, dependent: :restrict_with_error

  has_secure_password

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  def allowed_to?(permission)
    active? && role.grants?(permission)
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
