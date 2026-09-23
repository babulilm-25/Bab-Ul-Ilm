from pathlib import Path
p=Path("src/App.tsx")
s=p.read_text()
imp="import {DataImportPromotionPage,HrPayrollPage,ReportsEnhancedPage} from './phase16'"
s="\n".join(line for line in s.splitlines() if not line.startswith("import {DataImportPromotionPage,HrPayrollPage,ReportsEnhancedPage}"))+"\n"
s=s.replace("import type {Session} from '@supabase/supabase-js'","import type {Session} from '@supabase/supabase-js'\n"+imp,1)
s=s.replace("type Page='Dashboard'|'Users'|'Roles & Permissions'|'Branches'|'Institution Structure'|'Hostel & Mess'|'Security'|'Students'|'Student Enrollment'|'Academics'|'Teachers / Staff'|'Timetable & Attendance'|'Exams & Results'|'Fees & Finance'|'Library & Inventory'|'Reports & Certificates'|'Communication & Portal'",
"type Page='Dashboard'|'Users'|'Roles & Permissions'|'Branches'|'Institution Structure'|'Hostel & Mess'|'Security'|'Students'|'Student Enrollment'|'Academics'|'Teachers / Staff'|'HR & Payroll'|'Data Import & Promotion'|'Timetable & Attendance'|'Exams & Results'|'Fees & Finance'|'Library & Inventory'|'Reports & Certificates'|'Communication & Portal'")
s=s.replace("  'Teachers / Staff':{create:'teachers.create',edit:'teachers.create',delete:'teachers.delete'},","  'Teachers / Staff':{create:'teachers.create',edit:'teachers.edit',delete:'teachers.delete'},\n  'HR & Payroll':{create:'hr.create',edit:'hr.edit',delete:'hr.delete'},\n  'Data Import & Promotion':{create:'data.import',edit:'students.edit',delete:'students.edit'},")
s=s.replace("{label:'Teachers / Staff',icon:Users,permission:'teachers.edit'},","{label:'Teachers / Staff',icon:Users,permission:'teachers.edit'},{label:'HR & Payroll',icon:Users,permission:'hr.view'},{label:'Data Import & Promotion',icon:RefreshCw,permission:'data.import'},")
s=s.replace("{page==='Reports & Certificates'&&<ReportsCertificatesPage setError={setError}/>}", "{page==='Reports & Certificates'&&<ReportsEnhancedPage setError={setError}/>}") 
needle="{page==='Teachers / Staff'&&<StaffPage setError={setError}/>} "
s=s.replace(needle,needle+"{page==='HR & Payroll'&&<HrPayrollPage setError={setError}/>} {page==='Data Import & Promotion'&&<DataImportPromotionPage setError={setError}/>} ")
if "ReportsEnhancedPage" not in s or "HrPayrollPage" not in s or "DataImportPromotionPage" not in s: raise SystemExit("phase16 imports failed")
s=s.replace("\nfunction ReportsCertificatesPage(","\nexport function ReportsCertificatesPage(",1)
p.write_text(s)
