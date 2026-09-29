module Api
  class BaseController < ApplicationController
    include Authenticatable

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Not found" }, status: :not_found
    end
  end
end
