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
s=s.replace(needle,needle+"{page==='HR & Payroll'&&<HrPayrollPage setError={setError}/>} {page==='Data Import & Promotion'&&<DataImportPromotionPage setError={setError}/>} ")
if "ReportsEnhancedPage" not in s or "HrPayrollPage" not in s or "DataImportPromotionPage" not in s: raise SystemExit("phase16 imports failed")
s=s.replace("\nfunction ReportsCertificatesPage(","\nexport function ReportsCertificatesPage(",1)
# Premium UX / Settings wiring (idempotent)
if "from './premium'" not in s:
    s=s.replace("import type {Session} from '@supabase/supabase-js'","import type {Session} from '@supabase/supabase-js'\nimport {SettingsPage} from './premium'",1)
if "'Settings'" not in s.split("type Page=",1)[1].split("\n",1)[0]:
    s=s.replace("'Communication & Portal'","'Communication & Portal'|'Settings'",1)
if "{label:'Settings',icon:ShieldCheck,permission:'settings.view'}" not in s:
    s=s.replace("{label:'Communication & Portal',icon:BookOpen}","{label:'Communication & Portal',icon:BookOpen},{label:'Settings',icon:ShieldCheck,permission:'settings.view'}",1)
if "{page==='Settings'" not in s:
    s=s.replace("{page==='Communication & Portal'&&<CommunicationPortalPage setError={setError} roleSlugs={roleSlugs} superAdmin={superAdmin}/>}","{page==='Communication & Portal'&&<CommunicationPortalPage setError={setError} roleSlugs={roleSlugs} superAdmin={superAdmin}/>} {page==='Settings'&&<SettingsPage profile={profile} setError={setError} dark={dark} setDark={setDark}/>} ",1)
if "auth-pills" not in s:
    s=s.replace('<p className="eyebrow">Madarsa Management Platform</p><h1>Organise knowledge.<br/><em>Serve with excellence.</em></h1>','<p className="eyebrow">Madarsa Management Platform</p><h1>Organise knowledge.<br/><em>Serve with excellence.</em></h1><div className="auth-pills"><span>Secure</span><span>Cloud-first</span><span>Beautifully simple</span></div>',1)
# Keep repeated CI runs idempotent.
s=re.sub(r"(import \\{SettingsPage\\} from './premium'\\n)+", "import {SettingsPage} from './premium'\\n", s)
s=re.sub(r"(\\{label:'HR & Payroll',icon:Users,permission:'hr.view'\\},\\{label:'Data Import & Promotion',icon:RefreshCw,permission:'data.import'\\},)+", "{label:'HR & Payroll',icon:Users,permission:'hr.view'},{label:'Data Import & Promotion',icon:RefreshCw,permission:'data.import'},", s)
s=re.sub(r"(\\{page==='HR & Payroll'&&<HrPayrollPage setError=\\{setError\\}/>} \\{page==='Data Import & Promotion'&&<DataImportPromotionPage setError=\\{setError\\}/>\\} )+", "{page==='HR & Payroll'&&<HrPayrollPage setError={setError}/>} {page==='Data Import & Promotion'&&<DataImportPromotionPage setError={setError}/>} ", s)
p.write_text(s)
