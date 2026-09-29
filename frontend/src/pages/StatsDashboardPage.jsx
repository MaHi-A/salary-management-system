import { useEffect, useMemo, useState } from 'react'
import { apiClient } from '../api/client'
import { useMeta } from '../api/useMeta'

const formatters = {}

function money(amount, currency) {
  if (!formatters[currency]) {
    formatters[currency] = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency,
      maximumFractionDigits: 0,
    })
  }
  return formatters[currency].format(amount)
}

export default function StatsDashboardPage() {
  const [stats, setStats] = useState(null)
  const [error, setError] = useState(null)
  const { departments } = useMeta()
  const [selectedDepartment, setSelectedDepartment] = useState('')

  useEffect(() => {
    apiClient
      .get('/stats')
      .then((response) => setStats(response.data))
      .catch(() => setError('Could not load pay analytics.'))
  }, [])

  const departmentRows = useMemo(() => {
    if (!stats) return []
    if (!selectedDepartment) return stats.by_department
    return stats.by_department.filter((row) => row.department === selectedDepartment)
  }, [stats, selectedDepartment])

  if (error) return <p className="text-sm text-red-600">{error}</p>
  if (!stats) return <p className="text-slate-600">Loading...</p>

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-lg font-semibold text-slate-800">Pay Analytics</h1>
        <p className="text-sm text-slate-500">
          Salaries stay in each employee's local currency (no cross-currency conversion), so every
          figure below is scoped to a single currency and safe to compare within its own row.
        </p>
      </div>

      <div className="rounded-lg border border-slate-200 bg-white p-6">
        <p className="text-sm text-slate-500">Total headcount</p>
        <p className="text-2xl font-semibold text-slate-800">{stats.total_headcount.toLocaleString()}</p>
      </div>

      <section>
        <h2 className="mb-3 text-base font-semibold text-slate-800">Pay by country</h2>
        <StatsTable
          rows={stats.by_country}
          rowKey={(row) => row.country}
          columns={[{ key: 'country', label: 'Country' }]}
        />
      </section>

      <section>
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-base font-semibold text-slate-800">Pay by department</h2>
          <select
            value={selectedDepartment}
            onChange={(event) => setSelectedDepartment(event.target.value)}
            className="rounded border border-slate-300 px-3 py-1.5 text-sm"
          >
            <option value="">All departments</option>
            {departments.map((d) => (
              <option key={d} value={d}>
                {d}
              </option>
            ))}
          </select>
        </div>
        <StatsTable
          rows={departmentRows}
          rowKey={(row) => `${row.department}-${row.country}`}
          columns={[
            { key: 'department', label: 'Department' },
            { key: 'country', label: 'Country' },
          ]}
        />
      </section>
    </div>
  )
}

function StatsTable({ rows, columns, rowKey }) {
  return (
    <div className="overflow-hidden rounded-lg border border-slate-200 bg-white">
      <table className="w-full text-left text-sm">
        <thead className="bg-slate-50 text-slate-500">
          <tr>
            {columns.map((col) => (
              <th key={col.key} className="px-4 py-3">
                {col.label}
              </th>
            ))}
            <th className="px-4 py-3">Headcount</th>
            <th className="px-4 py-3">Average</th>
            <th className="px-4 py-3">Median</th>
            <th className="px-4 py-3">Min</th>
            <th className="px-4 py-3">Max</th>
            <th className="px-4 py-3">Total payroll</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-100">
          {rows.map((row) => (
            <tr key={rowKey(row)} className="hover:bg-slate-50">
              {columns.map((col) => (
                <td key={col.key} className="px-4 py-3 text-slate-700">
                  {row[col.key]}
                </td>
              ))}
              <td className="px-4 py-3 text-slate-600">{row.headcount.toLocaleString()}</td>
              <td className="px-4 py-3 text-slate-600">{money(row.average_salary, row.currency)}</td>
              <td className="px-4 py-3 text-slate-600">{money(row.median_salary, row.currency)}</td>
              <td className="px-4 py-3 text-slate-600">{money(row.min_salary, row.currency)}</td>
              <td className="px-4 py-3 text-slate-600">{money(row.max_salary, row.currency)}</td>
              <td className="px-4 py-3 text-slate-600">{money(row.total_payroll, row.currency)}</td>
            </tr>
          ))}
          {rows.length === 0 && (
            <tr>
              <td colSpan={columns.length + 6} className="px-4 py-6 text-center text-slate-400">
                No data.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  )
}
