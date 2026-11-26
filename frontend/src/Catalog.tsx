import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { api, errorMessage } from './api'
import Header from './Header'

export type Track = { id: number; title: string; performer: string; album: string; genre: string | null; duration: number }

export default function Catalog() {
  const [params, setParams] = useSearchParams()
  const query = params.toString()
  const [draft, setDraft] = useState({ title: params.get('title') ?? '', artist: params.get('artist') ?? '' })
  const [tracks, setTracks] = useState<Track[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [focused, setFocused] = useState(false)
  const [retry, setRetry] = useState(0)

  useEffect(() => {
    const search = new URLSearchParams(query)
    setDraft({ title: search.get('title') ?? '', artist: search.get('artist') ?? '' })
  }, [query])

  useEffect(() => {
    const next = new URLSearchParams()
    for (const [key, value] of Object.entries(draft)) if (value.trim()) next.set(key, value.trim())
    if (next.toString() === query) return
    const timer = window.setTimeout(() => setParams(next), 350)
    return () => window.clearTimeout(timer)
  }, [draft, query, setParams])

  useEffect(() => {
    const controller = new AbortController()
    setLoading(true); setError('')
    api<Track[]>(`/tracks?${query}`, { signal: controller.signal })
      .then(setTracks)
      .catch(err => { if (!controller.signal.aborted) setError(errorMessage(err)) })
      .finally(() => { if (!controller.signal.aborted) setLoading(false) })
    return () => controller.abort()
  }, [query, retry])

  const suggestions = focused && Object.values(draft).some(Boolean) && !loading && !error
  return <div className="app"><Header /><main>
    <section className="hero">
      <h1>Музыкальный каталог</h1><p>Найдите песню по названию или исполнителю. Для прослушивания войдите в аккаунт.</p>
    </section>
    <section className="catalog"><h2>Поиск песен</h2>
      <div className="search-area" onBlur={event => { if (!event.currentTarget.contains(event.relatedTarget)) setFocused(false) }} onKeyDown={event => { if (event.key === 'Escape') setFocused(false) }}>
        <div className="filters" onFocus={() => setFocused(true)}>
          <label>Название<input maxLength={100} value={draft.title} onChange={e => setDraft({ ...draft, title: e.target.value })} /></label>
          <label>Исполнитель<input maxLength={100} value={draft.artist} onChange={e => setDraft({ ...draft, artist: e.target.value })} /></label>
          <button className="login-button" onClick={() => { setDraft({ title: '', artist: '' }); setParams({}); setFocused(false) }}>Сбросить</button>
        </div>
        {suggestions && <ul className="suggestions" aria-label="Поисковые подсказки">
          {tracks.slice(0, 5).map(track => <li key={track.id}><Link to={`/music/${track.id}`}>{track.title} <span>— {track.performer}</span></Link></li>)}
          {!tracks.length && <li>Ничего не найдено</li>}
        </ul>}
      </div>
      {loading && <p role="status">Загрузка композиций…</p>}
      {error && <p role="alert" className="auth-error">{error} <button onClick={() => setRetry(retry + 1)}>Повторить</button></p>}
      {!loading && !error && !tracks.length && <p role="status">Композиции не найдены. Попробуйте изменить запрос.</p>}
      {!loading && !error && <div className="tracks">{tracks.map(track => <article className="track-card" key={track.id}>
        <div className="cover" aria-hidden="true">♫</div>
        <div className="track-info"><span className="level">{track.genre}</span><h3>{track.title}</h3><p>{track.performer}</p><small>{track.duration} сек. · {track.album}</small></div>
        <Link className="login-button" to={`/music/${track.id}`}>Открыть трек →</Link>
      </article>)}</div>}
    </section>
  </main></div>
}
