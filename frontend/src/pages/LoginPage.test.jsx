import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import LoginPage from './LoginPage.jsx'
import { useAuth } from '../auth/AuthContext.jsx'

vi.mock('../auth/AuthContext.jsx', () => ({
  useAuth: vi.fn(),
}))

describe('LoginPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('logs in and shows no error on success', async () => {
    const login = vi.fn().mockResolvedValue()
    useAuth.mockReturnValue({ login })

    render(
      <MemoryRouter>
        <LoginPage />
      </MemoryRouter>,
    )

    await userEvent.type(screen.getByLabelText('Email'), 'hr@acme.example')
    await userEvent.type(screen.getByLabelText('Password'), 'password123')
    await userEvent.click(screen.getByRole('button', { name: /sign in/i }))

    await waitFor(() => expect(login).toHaveBeenCalledWith('hr@acme.example', 'password123'))
    expect(screen.queryByText(/invalid email or password/i)).not.toBeInTheDocument()
  })

  it('shows an error message when login fails', async () => {
    const login = vi.fn().mockRejectedValue(new Error('unauthorized'))
    useAuth.mockReturnValue({ login })

    render(
      <MemoryRouter>
        <LoginPage />
      </MemoryRouter>,
    )

    await userEvent.type(screen.getByLabelText('Email'), 'hr@acme.example')
    await userEvent.type(screen.getByLabelText('Password'), 'wrong-password')
    await userEvent.click(screen.getByRole('button', { name: /sign in/i }))

    expect(await screen.findByText(/invalid email or password/i)).toBeInTheDocument()
  })
})
