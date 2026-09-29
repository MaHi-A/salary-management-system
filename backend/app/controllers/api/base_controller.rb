module Api
  class BaseController < ApplicationController
    include Authenticatable
  end
end
