class ApplicationController < ActionController::API
  private

  attr_reader :current_user

  def authenticate_user!
    session = ApiSession.authenticate(bearer_token)
    return render_unauthorized unless session&.user&.active?

    @current_user = session.user
  end

  def require_permission!(permission)
    return if current_user&.allowed_to?(permission)

    render json: { error: { code: "forbidden", message: "You do not have permission for this action." } }, status: :forbidden
  end

  def bearer_token
    request.authorization.to_s.delete_prefix("Bearer ").presence
  end

  def render_unauthorized
    render json: { error: { code: "unauthorized", message: "Authentication is required." } }, status: :unauthorized
  end
end
