import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from './AuthContext'
import { errorMessage } from './api'

export default function Header() {
  const { user, loading, error: authError, logout } = useAuth()
  const [error, setError] = useState('')
  const [busy, setBusy] = useState(false)
  async function leave() {
    setBusy(true); setError('')
    try { await logout() } catch (err) { setError(errorMessage(err)) }
    finally { setBusy(false) }
  }
  return <><header className="header">
    <Link className="logo" to="/">♫ FreeMusicService</Link>
    <nav aria-label="Аккаунт">
      {loading ? <span role="status">Загрузка…</span> : user ? <>
        <Link to="/account">{user.login}</Link>
        <button className="login-button" onClick={leave} disabled={busy}>Выйти</button>
      </> : <><Link to="/login">Войти</Link><Link className="login-button" to="/register">Регистрация</Link></>}
    </nav>
  </header>{(error || authError) && <p className="auth-error page-message" role="alert">{error || authError}</p>}</>
}
