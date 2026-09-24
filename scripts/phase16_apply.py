from pathlib import Path
p=Path("src/App.tsx")
s=p.read_text()
imp="import {DataImportPromotionPage,HrPayrollPage,ReportsEnhancedPage} from './phase16'"
premium_imp="import {SettingsPage} from './premium'"
s="\n".join(line for line in s.splitlines() if not line.startswith("import {DataImportPromotionPage,HrPayrollPage,ReportsEnhancedPage}"))+"\n"
s=s.replace("import type {Session} from '@supabase/supabase-js'","import type {Session} from '@supabase/supabase-js'\n"+imp+"\n"+premium_imp,1)
s=s.replace("type Page='Dashboard'|'Users'|'Roles & Permissions'|'Branches'|'Institution Structure'|'Hostel & Mess'|'Security'|'Students'|'Student Enrollment'|'Academics'|'Teachers / Staff'|'Timetable & Attendance'|'Exams & Results'|'Fees & Finance'|'Library & Inventory'|'Reports & Certificates'|'Communication & Portal'",
"type Page='Dashboard'|'Users'|'Roles & Permissions'|'Branches'|'Institution Structure'|'Hostel & Mess'|'Security'|'Students'|'Student Enrollment'|'Academics'|'Teachers / Staff'|'HR & Payroll'|'Data Import & Promotion'|'Timetable & Attendance'|'Exams & Results'|'Fees & Finance'|'Library & Inventory'|'Reports & Certificates'|'Communication & Portal'")
s=s.replace("  'Teachers / Staff':{create:'teachers.create',edit:'teachers.create',delete:'teachers.delete'},","  'Teachers / Staff':{create:'teachers.create',edit:'teachers.edit',delete:'teachers.delete'},\n  'HR & Payroll':{create:'hr.create',edit:'hr.edit',delete:'hr.delete'},\n  'Data Import & Promotion':{create:'data.import',edit:'students.edit',delete:'students.edit'},")
s=s.replace("{label:'Teachers / Staff',icon:Users,permission:'teachers.edit'},","{label:'Teachers / Staff',icon:Users,permission:'teachers.edit'},{label:'HR & Payroll',icon:Users,permission:'hr.view'},{label:'Data Import & Promotion',icon:RefreshCw,permission:'data.import'},")
s=s.replace("{page==='Reports & Certificates'&&<ReportsCertificatesPage setError={setError}/>}", "{page==='Reports & Certificates'&&<ReportsEnhancedPage setError={setError}/>}") 
needle="{page==='Teachers / Staff'&&<StaffPage setError={setError}/>} "
if "{page==='HR & Payroll'&&<HrPayrollPage setError={setError}/>} " not in s:
    s=s.replace(needle,needle+"{page==='HR & Payroll'&&<HrPayrollPage setError={setError}/>} ")
if "{page==='Data Import & Promotion'&&<DataImportPromotionPage setError={setError}/>} " not in s:
    s=s.replace("{page==='HR & Payroll'&&<HrPayrollPage setError={setError}/>} ","{page==='HR & Payroll'&&<HrPayrollPage setError={setError}/>} {page==='Data Import & Promotion'&&<DataImportPromotionPage setError={setError}/>} ",1)
if "ReportsEnhancedPage" not in s or "HrPayrollPage" not in s or "DataImportPromotionPage" not in s: raise SystemExit("phase16 imports failed")
s=s.replace("\nfunction ReportsCertificatesPage(","\nexport function ReportsCertificatesPage(",1)
# Premium UX / Settings wiring (idempotent)
# Remove any stale/generated copies first, then insert exactly one import.
lines=[line for line in s.splitlines() if line.strip()!="import {SettingsPage} from './premium'"]
s="\n".join(lines)+"\n"
if "import {SettingsPage} from './premium'" not in s:
    s=s.replace("import type {Session} from '@supabase/supabase-js'","import type {Session} from '@supabase/supabase-js'\nimport {SettingsPage} from './premium'",1)
if "'Settings'" not in s.split("type Page=",1)[1].split("\n",1)[0]:
    s=s.replace("'Communication & Portal'","'Communication & Portal'|'Settings'",1)
if "{label:'Settings',icon:ShieldCheck,permission:'settings.view'}" not in s and "{label:'Settings',icon:ShieldCheck}" not in s:
    s=s.replace("{label:'Communication & Portal',icon:BookOpen}","{label:'Communication & Portal',icon:BookOpen,permissions:['portal.view','communication.view']},{label:'Settings',icon:ShieldCheck,permission:'settings.view'}",1)
s=s.replace("{label:'Communication & Portal',icon:BookOpen}","{label:'Communication & Portal',icon:BookOpen,permissions:['portal.view','communication.view']}")
s=s.replace("{label:'Communication & Portal',icon:BookOpen,permission:'portal.view'}","{label:'Communication & Portal',icon:BookOpen,permissions:['portal.view','communication.view']}")
s=s.replace("{label:'Settings',icon:ShieldCheck,permission:'settings.view'},{label:'Settings',icon:ShieldCheck,permission:'settings.view'}","{label:'Settings',icon:ShieldCheck,permission:'settings.view'}")

if "{page==='Settings'" not in s:
    s=s.replace("{page==='Communication & Portal'&&<CommunicationPortalPage setError={setError} roleSlugs={roleSlugs} superAdmin={superAdmin}/>}","{page==='Communication & Portal'&&<CommunicationPortalPage setError={setError} roleSlugs={roleSlugs} superAdmin={superAdmin}/>} {page==='Settings'&&<SettingsPage profile={profile} setError={setError} dark={dark} setDark={setDark}/>} ",1)
if "auth-pills" not in s:
    s=s.replace('<p className="eyebrow">Madarsa Management Platform</p><h1>Organise knowledge.<br/><em>Serve with excellence.</em></h1>','<p className="eyebrow">Madarsa Management Platform</p><h1>Organise knowledge.<br/><em>Serve with excellence.</em></h1><div className="auth-pills"><span>Secure</span><span>Cloud-first</span><span>Beautifully simple</span></div>',1)
navPair="{label:'HR & Payroll',icon:Users,permission:'hr.view'},{label:'Data Import & Promotion',icon:RefreshCw,permission:'data.import'},"
while s.count(navPair)>1: s=s.replace(navPair+navPair,navPair,1)
renderPair="{page==='HR & Payroll'&&<HrPayrollPage setError={setError}/>} {page==='Data Import & Promotion'&&<DataImportPromotionPage setError={setError}/>} "
while s.count(renderPair)>1: s=s.replace(renderPair+renderPair,renderPair,1)
p.write_text(s)
