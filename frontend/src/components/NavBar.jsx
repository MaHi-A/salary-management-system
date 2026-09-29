import { NavLink } from 'react-router-dom'
import { useAuth } from '../auth/AuthContext.jsx'

const linkClass = ({ isActive }) =>
  `rounded px-3 py-2 text-sm font-medium ${
    isActive ? 'bg-slate-800 text-white' : 'text-slate-600 hover:bg-slate-100'
  }`

export default function NavBar() {
  const { email, logout } = useAuth()

  return (
    <nav className="flex items-center justify-between border-b border-slate-200 bg-white px-6 py-3">
      <div className="flex items-center gap-2">
        <span className="mr-4 font-semibold text-slate-800">ACME Salary Management</span>
        <NavLink to="/employees" className={linkClass}>
          Employees
        </NavLink>
        <NavLink to="/stats" className={linkClass}>
          Pay Analytics
        </NavLink>
      </div>
      <div className="flex items-center gap-3 text-sm text-slate-600">
        <span>{email}</span>
        <button onClick={logout} className="rounded px-3 py-1 text-slate-600 hover:bg-slate-100">
          Log out
        </button>
      </div>
    </nav>
  )
}
