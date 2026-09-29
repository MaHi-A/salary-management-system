module Api
  class MetaController < Api::BaseController
    def index
      render json: {
        countries: Employee::COUNTRIES,
        departments: Employee::DEPARTMENTS
      }
    end
  end
end
