import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { apiClient } from '../api/client'

const currencyFormatters = {}

function formatSalary(amount, currency) {
  if (!currencyFormatters[currency]) {
    currencyFormatters[currency] = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency,
      maximumFractionDigits: 0,
    })
  }
  return currencyFormatters[currency].format(amount)
}

export default function EmployeeListPage() {
  const [employees, setEmployees] = useState([])
  const [meta, setMeta] = useState({ current_page: 1, total_pages: 1, total_count: 0 })
  const [countries, setCountries] = useState([])
  const [departments, setDepartments] = useState([])

  const [q, setQ] = useState('')
  const [country, setCountry] = useState('')
  const [department, setDepartment] = useState('')
  const [sortBy, setSortBy] = useState('last_name')
  const [sortDir, setSortDir] = useState('asc')
  const [page, setPage] = useState(1)

  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    apiClient.get('/meta').then((response) => {
      setCountries(response.data.countries)
      setDepartments(response.data.departments)
    })
  }, [])

  useEffect(() => {
    setLoading(true)
    setError(null)

    const params = { q, country, department, sort_by: sortBy, sort_dir: sortDir, page }

    apiClient
      .get('/employees', { params })
      .then((response) => {
        setEmployees(response.data.employees)
        setMeta(response.data.meta)
      })
      .catch(() => setError('Could not load employees.'))
      .finally(() => setLoading(false))
  }, [q, country, department, sortBy, sortDir, page])

  function toggleSort(column) {
    if (sortBy === column) {
      setSortDir(sortDir === 'asc' ? 'desc' : 'asc')
    } else {
      setSortBy(column)
      setSortDir('asc')
    }
    setPage(1)
  }

  function handleFilterChange(setter) {
    return (event) => {
      setter(event.target.value)
      setPage(1)
    }
  }

  return (
    <div>
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-lg font-semibold text-slate-800">
          Employees {meta.total_count > 0 && <span className="text-slate-400">({meta.total_count})</span>}
        </h1>
        <Link
          to="/employees/new"
          className="rounded bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700"
        >
          Add employee
        </Link>
      </div>

      <div className="mb-4 flex flex-wrap gap-3">
        <input
          type="search"
          placeholder="Search by name or email"
          value={q}
          onChange={handleFilterChange(setQ)}
          className="w-64 rounded border border-slate-300 px-3 py-2 text-sm"
        />

        <select
          value={country}
          onChange={handleFilterChange(setCountry)}
          className="rounded border border-slate-300 px-3 py-2 text-sm"
        >
          <option value="">All countries</option>
          {countries.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>

        <select
          value={department}
          onChange={handleFilterChange(setDepartment)}
          className="rounded border border-slate-300 px-3 py-2 text-sm"
        >
          <option value="">All departments</option>
          {departments.map((d) => (
            <option key={d} value={d}>
              {d}
            </option>
          ))}
        </select>
      </div>

      {error && <p className="mb-4 text-sm text-red-600">{error}</p>}

      <div className="overflow-hidden rounded-lg border border-slate-200 bg-white">
        <table className="w-full text-left text-sm">
          <thead className="bg-slate-50 text-slate-500">
            <tr>
              <th className="cursor-pointer px-4 py-3" onClick={() => toggleSort('last_name')}>
                Name
              </th>
              <th className="px-4 py-3">Country</th>
              <th className="px-4 py-3">Department</th>
              <th className="px-4 py-3">Job title</th>
              <th className="cursor-pointer px-4 py-3" onClick={() => toggleSort('salary_cents')}>
                Salary {sortBy === 'salary_cents' && (sortDir === 'asc' ? '↑' : '↓')}
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {employees.map((employee) => (
              <tr key={employee.id} className="hover:bg-slate-50">
                <td className="px-4 py-3">
                  <Link to={`/employees/${employee.id}`} className="text-slate-800 hover:underline">
                    {employee.full_name}
                  </Link>
                </td>
                <td className="px-4 py-3 text-slate-600">{employee.country}</td>
                <td className="px-4 py-3 text-slate-600">{employee.department}</td>
                <td className="px-4 py-3 text-slate-600">{employee.job_title}</td>
                <td className="px-4 py-3 text-slate-600">
                  {formatSalary(employee.salary, employee.currency)}
                </td>
              </tr>
            ))}
            {!loading && employees.length === 0 && (
              <tr>
                <td colSpan={5} className="px-4 py-6 text-center text-slate-400">
                  No employees match these filters.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <div className="mt-4 flex items-center justify-between text-sm text-slate-600">
        <span>
          Page {meta.current_page} of {meta.total_pages || 1}
        </span>
        <div className="flex gap-2">
          <button
            disabled={page <= 1}
            onClick={() => setPage((p) => p - 1)}
            className="rounded border border-slate-300 px-3 py-1 disabled:opacity-40"
          >
            Previous
          </button>
          <button
            disabled={page >= (meta.total_pages || 1)}
            onClick={() => setPage((p) => p + 1)}
            className="rounded border border-slate-300 px-3 py-1 disabled:opacity-40"
          >
            Next
          </button>
        </div>
      </div>
    </div>
  )
}
