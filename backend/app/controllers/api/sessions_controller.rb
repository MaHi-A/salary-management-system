module Api
  class SessionsController < ApplicationController
    def create
      user = User.find_by(email: params[:email]&.downcase)

      if user&.authenticate(params[:password])
        token = JsonWebToken.encode({ user_id: user.id })
        render json: { token: token, email: user.email }, status: :created
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end
  end
end
