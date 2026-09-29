import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import StatsDashboardPage from './StatsDashboardPage.jsx'
import { apiClient } from '../api/client'

vi.mock('../api/client', () => ({
  apiClient: { get: vi.fn() },
}))

const STATS = {
  total_headcount: 3,
  by_country: [
    {
      country: 'India',
      currency: 'INR',
      headcount: 2,
      average_salary: 200,
      median_salary: 200,
      min_salary: 100,
      max_salary: 300,
      total_payroll: 400,
    },
  ],
  by_department: [
    {
      department: 'Engineering',
      country: 'India',
      currency: 'INR',
      headcount: 2,
      average_salary: 200,
      median_salary: 200,
      min_salary: 100,
      max_salary: 300,
      total_payroll: 400,
    },
  ],
}

describe('StatsDashboardPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders headcount and the country/department breakdowns', async () => {
    apiClient.get.mockImplementation((url) => {
      if (url === '/meta') return Promise.resolve({ data: { countries: [], departments: ['Engineering'] } })
      if (url === '/stats') return Promise.resolve({ data: STATS })
      return Promise.reject(new Error(`unexpected url ${url}`))
    })

    render(<StatsDashboardPage />)

    expect(await screen.findByText('3')).toBeInTheDocument()
    expect(screen.getAllByText('India').length).toBe(2)
    expect(screen.getAllByText('Engineering').length).toBeGreaterThan(0)
  })

  it('shows an error message when the stats request fails', async () => {
    apiClient.get.mockImplementation((url) => {
      if (url === '/meta') return Promise.resolve({ data: { countries: [], departments: [] } })
      return Promise.reject(new Error('network error'))
    })

    render(<StatsDashboardPage />)

    expect(await screen.findByText(/could not load pay analytics/i)).toBeInTheDocument()
  })
})
