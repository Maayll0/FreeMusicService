import { createContext, useContext, useEffect, useState } from 'react'
import type { ReactNode } from 'react'
import { api, ApiError, errorMessage } from './api'
import type { User } from './api'

type Auth = { user: User | null; loading: boolean; error: string; setUser: (value: User | null) => void; logout: () => Promise<void> }
const Context = createContext<Auth | null>(null)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  async function refresh() {
    setError('')
    try { setUser((await api<{ user: User }>('/me')).user) }
    catch (err) {
      if (err instanceof ApiError && err.status === 401) setUser(null)
      else setError(errorMessage(err))
    } finally { setLoading(false) }
  }
  useEffect(() => {
    const update = () => { void refresh() }
    update()
    window.addEventListener('focus', update)
    return () => window.removeEventListener('focus', update)
  }, [])
  async function logout() {
    try { await api('/logout', { method: 'POST' }) }
    catch (err) { if (!(err instanceof ApiError && err.status === 401)) throw err }
    setUser(null)
  }
  return <Context.Provider value={{ user, loading, error, setUser, logout }}>{children}</Context.Provider>
}

export function useAuth() {
  const auth = useContext(Context)
  if (!auth) throw new Error('AuthProvider required')
  return auth
}
