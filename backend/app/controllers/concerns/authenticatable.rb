module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end

  def current_user
    @current_user ||= user_from_token
  end

  def user_from_token
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")

    token = header.delete_prefix("Bearer ").strip
    payload = JsonWebToken.decode(token)
    return nil unless payload

    User.find_by(id: payload[:user_id])
  end
end
