import { Navigate, Route, Routes } from 'react-router-dom'
import ProtectedRoute from './components/ProtectedRoute.jsx'
import NavBar from './components/NavBar.jsx'
import LoginPage from './pages/LoginPage.jsx'
import EmployeeListPage from './pages/EmployeeListPage.jsx'
import EmployeeDetailPage from './pages/EmployeeDetailPage.jsx'
import EmployeeNewPage from './pages/EmployeeNewPage.jsx'
import StatsDashboardPage from './pages/StatsDashboardPage.jsx'

function AppLayout({ children }) {
  return (
    <div className="min-h-screen bg-slate-50">
      <NavBar />
      <main className="mx-auto max-w-6xl px-6 py-8">{children}</main>
    </div>
  )
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />

      <Route element={<ProtectedRoute />}>
        <Route
          path="/employees"
          element={
            <AppLayout>
              <EmployeeListPage />
            </AppLayout>
          }
        />
        <Route
          path="/employees/new"
          element={
            <AppLayout>
              <EmployeeNewPage />
            </AppLayout>
          }
        />
        <Route
          path="/employees/:id"
          element={
            <AppLayout>
              <EmployeeDetailPage />
            </AppLayout>
          }
        />
        <Route
          path="/stats"
          element={
            <AppLayout>
              <StatsDashboardPage />
            </AppLayout>
          }
        />
      </Route>

      <Route path="/" element={<Navigate to="/employees" replace />} />
      <Route path="*" element={<Navigate to="/employees" replace />} />
    </Routes>
  )
}
