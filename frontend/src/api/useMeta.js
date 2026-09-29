import { useEffect, useState } from 'react'
import { apiClient } from './client'

export function useMeta() {
  const [countries, setCountries] = useState([])
  const [departments, setDepartments] = useState([])

  useEffect(() => {
    apiClient.get('/meta').then((response) => {
      setCountries(response.data.countries)
      setDepartments(response.data.departments)
    })
  }, [])

  return { countries, departments }
}
