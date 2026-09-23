import {useEffect,useState} from 'react'
import {Check,Globe2,KeyRound,LogOut,Monitor, Moon, Palette, ShieldCheck, Smartphone, Sun, UserRound} from 'lucide-react'
import {supabase} from './lib/supabase'

type SettingsPageProps={profile:any;setError:(s:string)=>void;dark:boolean;setDark:(v:boolean)=>void}

export function SettingsPage({profile,setError,dark,setDark}:SettingsPageProps){
 const [name,setName]=useState(profile?.display_name??'')
 const [locale,setLocale]=useState(profile?.locale??'en')
 const [saved,setSaved]=useState(false)
 const [busy,setBusy]=useState(false)
 const [motion,setMotion]=useState(()=>localStorage.getItem('bab-reduced-motion')==='true')
 const [compact,setCompact]=useState(()=>localStorage.getItem('bab-compact')==='true')
 useEffect(()=>{setName(profile?.display_name??'');setLocale(profile?.locale??'en')},[profile?.display_name,profile?.locale])
 useEffect(()=>{document.documentElement.dataset.compact=compact?'true':'false';localStorage.setItem('bab-compact',String(compact))},[compact])
 useEffect(()=>{document.documentElement.dataset.reducedMotion=motion?'true':'false';localStorage.setItem('bab-reduced-motion',String(motion))},[motion])
 async function save(){
   setBusy(true);setSaved(false)
   const {error}=await supabase.from('profiles').update({display_name:name.trim()||null,locale,theme:dark?'dark':'light'}).eq('id',(await supabase.auth.getUser()).data.user?.id)
   if(error)setError(error.message);else{setSaved(true);setTimeout(()=>setSaved(false),2200)}
   setBusy(false)
 }
 async function signOut(){await supabase.auth.signOut()}
 return <section className="settings-page">
   <div className="settings-hero">
     <div><span className="badge">Personal workspace</span><h2>App Settings</h2><p>Apni app ko apne style aur device ke hisaab se customise karein.</p></div>
     <div className="settings-hero-icon"><Palette size={30}/></div>
   </div>
   <div className="settings-grid">
     <section className="settings-card">
       <div className="settings-card-head"><div className="settings-icon"><UserRound size={19}/></div><div><h3>Profile</h3><p>Your workspace identity</p></div></div>
       <label>Display name<input value={name} onChange={e=>setName(e.target.value)} placeholder="Your name"/></label>
       <label>Language<select value={locale} onChange={e=>setLocale(e.target.value)}><option value="en">English</option><option value="ur">اردو — Urdu (RTL)</option></select></label>
     </section>
     <section className="settings-card">
       <div className="settings-card-head"><div className="settings-icon"><Monitor size={19}/></div><div><h3>Appearance</h3><p>Premium display controls</p></div></div>
       <SettingToggle icon={dark?<Moon/>:<Sun/>} title="Dark mode" text={dark?'Dark theme enabled':'Light theme enabled'} on={dark} onChange={setDark}/>
       <SettingToggle icon={<Smartphone/>} title="Compact layout" text={compact?'Tighter spacing for small screens':'Comfortable spacing'} on={compact} onChange={setCompact}/>
       <SettingToggle icon={<Globe2/>} title="Reduced motion" text={motion?'Animations minimised':'Smooth premium animations'} on={motion} onChange={setMotion}/>
     </section>
     <section className="settings-card">
       <div className="settings-card-head"><div className="settings-icon"><ShieldCheck size={19}/></div><div><h3>Security</h3><p>Keep your account protected</p></div></div>
       <div className="settings-row"><div><strong>Authentication</strong><small>Password + Supabase session security</small></div><span className="settings-status"><Check size={14}/> Active</span></div>
       <div className="settings-row"><div><strong>MFA</strong><small>Authenticator setup is available from Security.</small></div><button className="ghost small" onClick={()=>{setError('Open Security from the navigation to manage MFA.')}}>Manage</button></div>
     </section>
     <section className="settings-card">
       <div className="settings-card-head"><div className="settings-icon"><KeyRound size={19}/></div><div><h3>Session</h3><p>Control this device session</p></div></div>
       <div className="settings-row"><div><strong>Signed in as</strong><small>{(profile as any)?.display_name||'Account user'}</small></div></div>
       <button className="danger settings-signout" onClick={signOut}><LogOut size={17}/> Sign out</button>
     </section>
   </div>
   <div className="settings-savebar"><div>{saved&&<span className="settings-saved"><Check size={16}/> Settings saved</span>}</div><button className="primary" disabled={busy} onClick={save}>{busy?'Saving…':'Save settings'}</button></div>
 </section>
}

function SettingToggle({icon,title,text,on,onChange}:{icon:any;title:string;text:string;on:boolean;onChange:(v:boolean)=>void}){
 return <button type="button" className="setting-toggle" onClick={()=>onChange(!on)} aria-pressed={on}><span className="setting-toggle-icon">{icon}</span><span className="setting-toggle-copy"><strong>{title}</strong><small>{text}</small></span><span className={on?'toggle on':'toggle'}><span/></span></button>
}
