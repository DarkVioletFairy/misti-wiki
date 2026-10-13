module Api
  module V1
    class SessionsController < ApplicationController
      before_action :authenticate_user!, only: %i[show destroy]

      def create
        user = User.includes(:role).find_by(email: params[:email].to_s.strip.downcase)

        unless user&.active? && user.authenticate(params[:password].to_s)
          return render json: { error: { code: "invalid_credentials", message: "Email or password is invalid." } }, status: :unauthorized
        end

        _session, token = ApiSession.issue_for!(user)
        render json: session_payload(user, token), status: :created
      end

      def show
        render json: session_payload(current_user)
      end

      def destroy
        ApiSession.authenticate(bearer_token)&.destroy!
        head :no_content
      end

      private

      def session_payload(user, token = nil)
        {
          token: token,
          user: {
            id: user.id,
            email: user.email,
            role: user.role.name
          }
        }.compact
      end
    end
  end
end
