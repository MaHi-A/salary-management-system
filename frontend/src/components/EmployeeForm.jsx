import { useState } from 'react'

const FIELD_CLASS = 'w-full rounded border border-slate-300 px-3 py-2 text-sm'
const LABEL_CLASS = 'mb-1 block text-sm font-medium text-slate-700'

export default function EmployeeForm({
  initialValues,
  countries,
  departments,
  onSubmit,
  submitLabel,
}) {
  const [values, setValues] = useState(initialValues)
  const [errors, setErrors] = useState([])
  const [submitting, setSubmitting] = useState(false)

  function update(field) {
    return (event) => setValues((prev) => ({ ...prev, [field]: event.target.value }))
  }

  async function handleSubmit(event) {
    event.preventDefault()
    setErrors([])
    setSubmitting(true)

    try {
      await onSubmit(values)
    } catch (error) {
      setErrors(error.response?.data?.errors ?? ['Something went wrong.'])
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="max-w-lg space-y-4 rounded-lg border border-slate-200 bg-white p-6">
      {errors.length > 0 && (
        <ul className="rounded border border-red-200 bg-red-50 p-3 text-sm text-red-700">
          {errors.map((message) => (
            <li key={message}>{message}</li>
          ))}
        </ul>
      )}

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className={LABEL_CLASS} htmlFor="first_name">First name</label>
          <input
            id="first_name"
            required
            value={values.first_name}
            onChange={update('first_name')}
            className={FIELD_CLASS}
          />
        </div>
        <div>
          <label className={LABEL_CLASS} htmlFor="last_name">Last name</label>
          <input
            id="last_name"
            required
            value={values.last_name}
            onChange={update('last_name')}
            className={FIELD_CLASS}
          />
        </div>
      </div>

      <div>
        <label className={LABEL_CLASS} htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          required
          value={values.email}
          onChange={update('email')}
          className={FIELD_CLASS}
        />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className={LABEL_CLASS} htmlFor="country">Country</label>
          <select id="country" required value={values.country} onChange={update('country')} className={FIELD_CLASS}>
            <option value="" disabled>
              Select a country
            </option>
            {countries.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label className={LABEL_CLASS} htmlFor="department">Department</label>
          <select
            id="department"
            required
            value={values.department}
            onChange={update('department')}
            className={FIELD_CLASS}
          >
            <option value="" disabled>
              Select a department
            </option>
            {departments.map((d) => (
              <option key={d} value={d}>
                {d}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div>
        <label className={LABEL_CLASS} htmlFor="job_title">Job title</label>
        <input
          id="job_title"
          required
          value={values.job_title}
          onChange={update('job_title')}
          className={FIELD_CLASS}
        />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className={LABEL_CLASS} htmlFor="salary">Salary (local currency)</label>
          <input
            id="salary"
            type="number"
            min="0"
            step="0.01"
            required
            value={values.salary}
            onChange={update('salary')}
            className={FIELD_CLASS}
          />
        </div>
        <div>
          <label className={LABEL_CLASS} htmlFor="hired_on">Hire date</label>
          <input
            id="hired_on"
            type="date"
            required
            value={values.hired_on}
            onChange={update('hired_on')}
            className={FIELD_CLASS}
          />
        </div>
      </div>

      <button
        type="submit"
        disabled={submitting}
        className="rounded bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700 disabled:opacity-50"
      >
        {submitting ? 'Saving...' : submitLabel}
      </button>
    </form>
  )
}
