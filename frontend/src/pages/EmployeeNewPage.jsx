import { useNavigate } from 'react-router-dom'
import { apiClient } from '../api/client'
import { useMeta } from '../api/useMeta'
import EmployeeForm from '../components/EmployeeForm.jsx'

const BLANK_EMPLOYEE = {
  first_name: '',
  last_name: '',
  email: '',
  country: '',
  department: '',
  job_title: '',
  salary: '',
  hired_on: '',
}

export default function EmployeeNewPage() {
  const { countries, departments } = useMeta()
  const navigate = useNavigate()

  async function handleSubmit(values) {
    const response = await apiClient.post('/employees', { employee: values })
    navigate(`/employees/${response.data.id}`)
  }

  return (
    <div>
      <h1 className="mb-4 text-lg font-semibold text-slate-800">Add employee</h1>
      <EmployeeForm
        initialValues={BLANK_EMPLOYEE}
        countries={countries}
        departments={departments}
        onSubmit={handleSubmit}
        submitLabel="Create employee"
      />
    </div>
  )
}
