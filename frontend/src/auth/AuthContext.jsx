import { createContext, useContext, useState } from 'react'
import { apiClient } from '../api/client'

const AuthContext = createContext(null)
const STORAGE_KEY = 'acme_salary_token'

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => localStorage.getItem(STORAGE_KEY))
  const [email, setEmail] = useState(null)

  async function login(loginEmail, password) {
    const response = await apiClient.post('/login', { email: loginEmail, password })
    localStorage.setItem(STORAGE_KEY, response.data.token)
    setToken(response.data.token)
    setEmail(response.data.email)
  }

  function logout() {
    localStorage.removeItem(STORAGE_KEY)
    setToken(null)
    setEmail(null)
  }

  const value = { token, email, isAuthenticated: Boolean(token), login, logout }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used within an AuthProvider')
  return context
}
