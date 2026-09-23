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
p.write_text(s)

q=Path("src/phase16.tsx")
t=q.read_text()
t=t.replace("import {supabase} from './lib/supabase'","import {supabase} from './lib/supabase'\nimport * as XLSX from 'xlsx'")
old="async function importFile(file:File){setBusy(true);setMessage('');try{let text=await file.text();if(file.name.toLowerCase().endsWith('.xlsx')||file.name.toLowerCase().endsWith('.xls')){setMessage('Excel import is supported through Excel-compatible CSV export; choose CSV if your workbook is not directly readable in this build.');setBusy(false);return}const rows=csvParse(text);"
new="async function importFile(file:File){setBusy(true);setMessage('');try{let rows:string[][];if(/\\.xlsx?$/i.test(file.name)){const wb=XLSX.read(await file.arrayBuffer(),{type:'array'});const ws=wb.Sheets[wb.SheetNames[0]];rows=(XLSX.utils.sheet_to_json(ws,{header:1,raw:false,defval:''}) as any[]).map(r=>(r as any[]).map(v=>String(v??'')))}else{rows=csvParse(await file.text())}"
if old not in t: raise SystemExit("Excel import target not found")
t=t.replace(old,new)
t=t.replace('accept=".csv,text/csv"','accept=".csv,.xlsx,.xls,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/vnd.ms-excel"')
t=t.replace('>Import CSV<','>Import CSV / Excel<')
t=t.replace('CSV columns: admission_no, first_name, last_name, roll_no, gender, date_of_birth, phone, email, guardian_name, guardian_phone, status, joined_on, notes.','CSV/Excel columns: admission_no, first_name, last_name, roll_no, gender, date_of_birth, phone, email, guardian_name, guardian_phone, status, joined_on, notes.')
q.write_text(t)

# Remove legacy report page now replaced by ReportsEnhancedPage.\nimport re\ns=re.sub(r'\\nfunction ReportsCertificatesPage\\(.*?\\n}\\n\\n\\nfunction CommunicationPortalPage', '\\nfunction CommunicationPortalPage', s, flags=re.S)\np.write_text(s)\n