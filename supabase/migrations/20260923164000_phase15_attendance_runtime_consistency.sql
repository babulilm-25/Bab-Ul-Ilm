-- Phase 15: attendance runtime consistency and duplicate protection
alter table public.attendance_sessions
  add constraint attendance_sessions_class_date_period_key
  unique (class_id, attendance_date, period_no);

alter table public.attendance_sessions
  drop constraint if exists attendance_sessions_status_check;

alter table public.attendance_sessions
  add constraint attendance_sessions_status_check
  check (status = any (array['open'::text,'submitted'::text,'locked'::text]));

alter table public.attendance_records
  drop constraint if exists attendance_records_status_check;

alter table public.attendance_records
  add constraint attendance_records_status_check
  check (status = any (array['present'::text,'absent'::text,'late'::text,'leave'::text,'half_day'::text]));
