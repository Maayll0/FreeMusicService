import { useEffect, useRef, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { api, errorMessage } from './api'
import { useAuth } from './AuthContext'
import type { Track } from './Catalog'

export default function AudioPlayer({ track }: { track: Track }) {
  const { user, setUser } = useAuth()
  const [source, setSource] = useState('')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [catalog, setCatalog] = useState<Track[]>([])
  const audio = useRef<HTMLAudioElement>(null)
  const pending = useRef<AbortController | null>(null)
  const navigate = useNavigate()
  const userId = user?.id
  const index = catalog.findIndex(item => item.id === track.id)

  useEffect(() => {
    setSource(''); setError(''); setBusy(false)
    return () => { pending.current?.abort() }
  }, [track.id, userId])

  useEffect(() => {
    if (!userId) { setCatalog([]); return }
    const controller = new AbortController()
    api<Track[]>('/tracks', { signal: controller.signal }).then(setCatalog)
      .catch(err => { if (!controller.signal.aborted) setError(errorMessage(err)) })
    return () => controller.abort()
  }, [userId, track.id])

  useEffect(() => {
    const element = audio.current
    if (source && element) {
      element.volume = 0.6
      void element.play().catch(() => {})
    }
    return () => { if (element) element.pause() }
  }, [source])

  async function checkStream() {
    pending.current?.abort()
    const controller = new AbortController()
    pending.current = controller
    const url = `/api/tracks/${track.id}/stream`
    try {
      const response = await fetch(url, {
        credentials: 'same-origin', headers: { Range: 'bytes=0-0' }, signal: controller.signal,
      })
      await response.body?.cancel()
      if (controller.signal.aborted) return
      if (response.status === 401) {
        setUser(null)
        navigate('/login')
      } else if (response.status === 403) {
        navigate('/access-denied')
      } else if (!response.ok) {
        setError(response.status === 404 ? 'Аудиофайл не найден' : 'Аудиофайл недоступен')
      } else {
        return url
      }
    } catch (err) {
      if (!controller.signal.aborted) setError(errorMessage(err))
    }
  }

  async function prepare() {
    setBusy(true)
    setError('')
    const url = await checkStream()
    if (url) setSource(url)
    setBusy(false)
  }

  async function mediaError() {
    setSource('')
    setError('Не удалось воспроизвести аудио')
    await checkStream()
  }

  if (!user) return <p><Link to="/login">Войдите</Link>, чтобы слушать музыку.</p>
  return <section className="player" aria-label={`Плеер: ${track.title}`}>
    {!source && <button className="login-button" disabled={busy} onClick={prepare}>{busy ? 'Открываем аудио…' : '▶ Слушать'}</button>}
    {source && <audio ref={audio} src={source} controls preload="metadata" onError={() => void mediaError()} />}
    {error && <p role="alert" className="auth-error">{error}</p>}
    <div className="player-navigation">
      <button disabled={index <= 0} onClick={() => navigate(`/music/${catalog[index - 1].id}`)}>← Предыдущий</button>
      <button disabled={index < 0 || index >= catalog.length - 1} onClick={() => navigate(`/music/${catalog[index + 1].id}`)}>Следующий →</button>
    </div>
  </section>
}
