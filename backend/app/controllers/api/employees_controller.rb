module Api
  class EmployeesController < Api::BaseController
    SORTABLE_COLUMNS = %w[salary_cents last_name hired_on].freeze
    DEFAULT_PER_PAGE = 25
    MAX_PER_PAGE = 100

    def index
      employees = Employee
        .search(params[:q])
        .in_country(params[:country])
        .in_department(params[:department])
        .order(sort_clause)
        .page(params[:page])
        .per(per_page)

      render json: {
        employees: employees.map { |employee| employee_json(employee) },
        meta: {
          current_page: employees.current_page,
          total_pages: employees.total_pages,
          total_count: employees.total_count
        }
      }
    end

    def show
      render json: employee_json(employee)
    end

    def create
      employee = Employee.new(employee_params)

      if employee.save
        render json: employee_json(employee), status: :created
      else
        render json: { errors: employee.errors.full_messages }, status: :unprocessable_content
      end
    end

    def update
      if employee.update(employee_params)
        render json: employee_json(employee)
      else
        render json: { errors: employee.errors.full_messages }, status: :unprocessable_content
      end
    end

    def destroy
      employee.destroy!
      head :no_content
    end

    private

    def employee
      @employee ||= Employee.find(params[:id])
    end

    def employee_params
      params.require(:employee).permit(
        :first_name, :last_name, :email, :country, :department,
        :job_title, :salary, :hired_on
      )
    end

    def sort_clause
      column = SORTABLE_COLUMNS.include?(params[:sort_by]) ? params[:sort_by] : "last_name"
      direction = params[:sort_dir] == "desc" ? :desc : :asc
      { column => direction }
    end

    def per_page
      requested = params[:per_page].to_i
      return DEFAULT_PER_PAGE if requested <= 0

      [ requested, MAX_PER_PAGE ].min
    end

    def employee_json(employee)
      {
        id: employee.id,
        first_name: employee.first_name,
        last_name: employee.last_name,
        full_name: employee.full_name,
        email: employee.email,
        country: employee.country,
        department: employee.department,
        job_title: employee.job_title,
        salary: employee.salary,
        currency: employee.currency,
        hired_on: employee.hired_on
      }
    end
  end
end
