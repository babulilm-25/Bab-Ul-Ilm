-- Phase 17: timetable and attendance hardening
create unique index if not exists attendance_records_session_student_uidx
  on public.attendance_records(session_id, student_id);

create unique index if not exists attendance_sessions_class_date_period_uidx
  on public.attendance_sessions(class_id, attendance_date, coalesce(period_no, 0));

create index if not exists attendance_records_student_created_idx
  on public.attendance_records(student_id, created_at desc);

create index if not exists attendance_sessions_class_date_idx
  on public.attendance_sessions(class_id, attendance_date desc);

create index if not exists timetable_entries_class_weekday_period_idx
  on public.timetable_entries(class_id, weekday, period_no)
  where active = true;
