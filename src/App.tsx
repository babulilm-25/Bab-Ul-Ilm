import { useEffect, useMemo, useState } from 'react'
import { BookOpen, Building2, ChevronRight, CircleUserRound, GraduationCap, LayoutDashboard, LogOut, Menu, Moon, ShieldCheck, Sun, Users, X } from 'lucide-react'
import { supabase } from './lib/supabase'
import type { Session } from '@supabase/supabase-js'

const nav = [
  {label:'Dashboard',icon:LayoutDashboard},
  {label:'Students',icon:GraduationCap},
  {label:'Teachers & Staff',icon:Users},
  {label:'Academics',icon:BookOpen},
  {label:'Branches',icon:Building2},
  {label:'Security',icon:ShieldCheck},
]

function App(){
  const [session,setSession]=useState<Session|null>(null)
  const [loading,setLoading]=useState(true)
  const [email,setEmail]=useState('')
  const [password,setPassword]=useState('')
  const [error,setError]=useState('')
  const [menu,setMenu]=useState(false)
  const [dark,setDark]=useState(()=>localStorage.getItem('bab-theme')==='dark')

  useEffect(()=>{
    document.documentElement.dataset.theme=dark?'dark':'light'
    localStorage.setItem('bab-theme',dark?'dark':'light')
  },[dark])

  useEffect(()=>{
    supabase.auth.getSession().then(({data})=>{setSession(data.session);setLoading(false)})
    const {data:{subscription}}=supabase.auth.onAuthStateChange((_event,next)=>setSession(next))
    return ()=>subscription.unsubscribe()
  },[])

  const userEmail=useMemo(()=>session?.user.email ?? '',[session])

  async function login(e:React.FormEvent){
    e.preventDefault(); setError('')
    const {error}=await supabase.auth.signInWithPassword({email,password})
    if(error)setError(error.message)
  }

  async function logout(){await supabase.auth.signOut()}

  if(loading)return <div className="splash"><div className="brand-mark">ب</div><strong>Bab UL Ilm</strong><span>Loading secure workspace…</span></div>

  if(!session)return <main className="auth-shell">
    <section className="auth-art">
      <div className="brand-mark large">ب</div>
      <p className="eyebrow">Madarsa Management Platform</p>
      <h1>Organise knowledge.<br/><em>Serve with excellence.</em></h1>
      <p className="muted">A cloud-first platform for Madarsa Ahle Sunnat Bab UL Ilm Raza E Mustafa.</p>
    </section>
    <form className="auth-card" onSubmit={login}>
      <div><p className="eyebrow">Secure sign in</p><h2>Welcome back</h2><p className="muted">Sign in with your institution account.</p></div>
      <label>Email<input type="email" value={email} onChange={e=>setEmail(e.target.value)} autoComplete="email" required /></label>
      <label>Password<input type="password" value={password} onChange={e=>setPassword(e.target.value)} autoComplete="current-password" required /></label>
      {error&&<div className="error">{error}</div>}
      <button className="primary" type="submit">Sign in <ChevronRight size={18}/></button>
      <small>Authentication is handled by Supabase Auth. Authorization is enforced by database RLS.</small>
    </form>
  </main>

  return <div className="app-shell">
    <aside className={menu?'sidebar open':'sidebar'}>
      <div className="sidebar-head"><div className="brand-mark">ب</div><div><strong>Bab UL Ilm</strong><small>Admin Console</small></div><button className="icon mobile-only" onClick={()=>setMenu(false)} aria-label="Close menu"><X size={20}/></button></div>
      <nav>{nav.map(item=><button key={item.label} className={item.label==='Dashboard'?'nav-item active':'nav-item'} onClick={()=>setMenu(false)}><item.icon size={19}/><span>{item.label}</span></button>)}</nav>
      <div className="sidebar-foot"><div className="user-mini"><CircleUserRound size={20}/><div><strong>{userEmail}</strong><small>Authenticated user</small></div></div><button className="nav-item" onClick={logout}><LogOut size={19}/>Sign out</button></div>
    </aside>
    {menu&&<button className="backdrop" onClick={()=>setMenu(false)} aria-label="Close navigation"/>}
    <section className="content">
      <header className="topbar"><button className="icon mobile-only" onClick={()=>setMenu(true)} aria-label="Open menu"><Menu/></button><div><p className="eyebrow">Institution workspace</p><h1>Dashboard</h1></div><button className="icon" onClick={()=>setDark(v=>!v)} aria-label="Toggle theme">{dark?<Sun/>:<Moon/>}</button></header>
      <main className="page">
        <div className="hero"><div><span className="badge">Foundation online</span><h2>Assalamu Alaikum 👋</h2><p>Bab UL Ilm is connected to its cloud workspace. Core administration modules are being built on this foundation.</p></div><div className="hero-orb">ب</div></div>
        <div className="stats"><article><span>Platform</span><strong>Cloud-first</strong><small>Supabase PostgreSQL</small></article><article><span>Security</span><strong>RLS-ready</strong><small>Database-side authorization</small></article><article><span>Mobile</span><strong>Capacitor</strong><small>Android + future iOS</small></article><article><span>Languages</span><strong>EN + اردو</strong><small>RTL architecture ready</small></article></div>
        <section className="panel"><div><p className="eyebrow">Next modules</p><h3>Administration foundation</h3></div><div className="module-grid">{['Users & Roles','Branches','Students','Academics','Attendance','Finance'].map((x,i)=><div className="module" key={x}><span>0{i+1}</span><strong>{x}</strong><small>Database-backed module</small></div>)}</div></section>
      </main>
    </section>
  </div>
}

export default App
