import { useEffect, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { apiClient } from '../api/client'
import { useMeta } from '../api/useMeta'
import EmployeeForm from '../components/EmployeeForm.jsx'

export default function EmployeeDetailPage() {
  const { id } = useParams()
  const { countries, departments } = useMeta()
  const navigate = useNavigate()

  const [employee, setEmployee] = useState(null)
  const [editing, setEditing] = useState(false)
  const [notFound, setNotFound] = useState(false)

  useEffect(() => {
    apiClient
      .get(`/employees/${id}`)
      .then((response) => setEmployee(response.data))
      .catch(() => setNotFound(true))
  }, [id])

  async function handleSubmit(values) {
    const response = await apiClient.patch(`/employees/${id}`, { employee: values })
    setEmployee(response.data)
    setEditing(false)
  }

  async function handleDelete() {
    if (!window.confirm(`Remove ${employee.full_name}? This cannot be undone.`)) return

    await apiClient.delete(`/employees/${id}`)
    navigate('/employees')
  }

  if (notFound) {
    return (
      <div>
        <p className="text-slate-600">Employee not found.</p>
        <Link to="/employees" className="text-sm text-slate-800 underline">
          Back to employees
        </Link>
      </div>
    )
  }

  if (!employee) {
    return <p className="text-slate-600">Loading...</p>
  }

  if (editing) {
    return (
      <div>
        <h1 className="mb-4 text-lg font-semibold text-slate-800">Edit {employee.full_name}</h1>
        <EmployeeForm
          initialValues={{
            first_name: employee.first_name,
            last_name: employee.last_name,
            email: employee.email,
            country: employee.country,
            department: employee.department,
            job_title: employee.job_title,
            salary: employee.salary,
            hired_on: employee.hired_on,
          }}
          countries={countries}
          departments={departments}
          onSubmit={handleSubmit}
          submitLabel="Save changes"
        />
        <button
          onClick={() => setEditing(false)}
          className="mt-3 text-sm text-slate-500 hover:underline"
        >
          Cancel
        </button>
      </div>
    )
  }

  return (
    <div className="max-w-lg">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-lg font-semibold text-slate-800">{employee.full_name}</h1>
        <div className="flex gap-2">
          <button
            onClick={() => setEditing(true)}
            className="rounded border border-slate-300 px-3 py-1.5 text-sm hover:bg-slate-100"
          >
            Edit
          </button>
          <button
            onClick={handleDelete}
            className="rounded border border-red-200 px-3 py-1.5 text-sm text-red-600 hover:bg-red-50"
          >
            Remove
          </button>
        </div>
      </div>

      <dl className="grid grid-cols-2 gap-4 rounded-lg border border-slate-200 bg-white p-6 text-sm">
        <Field label="Email" value={employee.email} />
        <Field label="Job title" value={employee.job_title} />
        <Field label="Country" value={employee.country} />
        <Field label="Department" value={employee.department} />
        <Field label="Salary" value={`${employee.currency} ${employee.salary.toLocaleString()}`} />
        <Field label="Hired on" value={employee.hired_on} />
      </dl>

      <Link to="/employees" className="mt-4 inline-block text-sm text-slate-500 hover:underline">
        Back to employees
      </Link>
    </div>
  )
}

function Field({ label, value }) {
  return (
    <div>
      <dt className="text-slate-400">{label}</dt>
      <dd className="text-slate-800">{value}</dd>
    </div>
  )
}
