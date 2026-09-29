import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import EmployeeListPage from './EmployeeListPage.jsx'
import { apiClient } from '../api/client'

vi.mock('../api/client', () => ({
  apiClient: { get: vi.fn() },
}))

const META = { countries: ['United States', 'India'], departments: ['Engineering', 'Sales'] }

function employeesResponse(employees, meta = {}) {
  return {
    data: {
      employees,
      meta: { current_page: 1, total_pages: 1, total_count: employees.length, ...meta },
    },
  }
}

describe('EmployeeListPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders employees returned by the API', async () => {
    apiClient.get.mockImplementation((url) => {
      if (url === '/meta') return Promise.resolve({ data: META })
      return Promise.resolve(
        employeesResponse([
          {
            id: 1,
            full_name: 'Priya Nair',
            country: 'India',
            department: 'Engineering',
            job_title: 'Software Engineer',
            salary: 2000000,
            currency: 'INR',
          },
        ]),
      )
    })

    render(
      <MemoryRouter>
        <EmployeeListPage />
      </MemoryRouter>,
    )

    expect(await screen.findByText('Priya Nair')).toBeInTheDocument()
    expect(screen.getAllByText('Engineering').length).toBeGreaterThan(0)
  })

  it('shows an empty state when no employees match', async () => {
    apiClient.get.mockImplementation((url) => {
      if (url === '/meta') return Promise.resolve({ data: META })
      return Promise.resolve(employeesResponse([]))
    })

    render(
      <MemoryRouter>
        <EmployeeListPage />
      </MemoryRouter>,
    )

    expect(await screen.findByText(/no employees match these filters/i)).toBeInTheDocument()
  })

  it('re-fetches with the search term when the user types', async () => {
    apiClient.get.mockImplementation((url) => {
      if (url === '/meta') return Promise.resolve({ data: META })
      return Promise.resolve(employeesResponse([]))
    })

    render(
      <MemoryRouter>
        <EmployeeListPage />
      </MemoryRouter>,
    )

    await screen.findByPlaceholderText(/search by name or email/i)
    await userEvent.type(screen.getByPlaceholderText(/search by name or email/i), 'nair')

    await waitFor(() => {
      const call = apiClient.get.mock.calls.findLast(([url]) => url === '/employees')
      expect(call[1].params.q).toBe('nair')
    })
  })
})
