class ApiSession < ApplicationRecord
  TOKEN_BYTES = 32

  belongs_to :user

  validates :token_digest, :expires_at, presence: true

  scope :active, -> { where("expires_at > ?", Time.current) }

  def self.issue_for!(user, expires_at: 14.days.from_now)
    token = SecureRandom.urlsafe_base64(TOKEN_BYTES)
    session = user.api_sessions.create!(token_digest: digest(token), expires_at: expires_at)

    [ session, token ]
  end

  def self.authenticate(token)
    return if token.blank?

    active.includes(:user).find_by(token_digest: digest(token))
  end

  def self.digest(token)
    Digest::SHA256.hexdigest(token)
  end
  private_class_method :digest
end
