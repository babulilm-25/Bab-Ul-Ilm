-- Phase 17: timetable and attendance hardening
create unique index if not exists attendance_sessions_class_date_period_uidx
  on public.attendance_sessions(class_id, attendance_date, coalesce(period_no, 0));

create index if not exists attendance_records_student_created_idx
  on public.attendance_records(student_id, created_at desc);

create index if not exists attendance_sessions_class_date_idx
  on public.attendance_sessions(class_id, attendance_date desc);

create index if not exists timetable_entries_class_weekday_period_idx
  on public.timetable_entries(class_id, weekday, period_no)
  where active = true;

drop policy if exists attendance_records_write on public.attendance_records;
drop policy if exists attendance_records_insert on public.attendance_records;
drop policy if exists attendance_records_update on public.attendance_records;
drop policy if exists attendance_records_delete on public.attendance_records;
create policy attendance_records_insert on public.attendance_records for insert to authenticated
  with check (app_private.is_super_admin() or (app_private.has_permission('attendance.create') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy attendance_records_update on public.attendance_records for update to authenticated
  using (app_private.is_super_admin() or (app_private.has_permission('attendance.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))))
  with check (app_private.is_super_admin() or (app_private.has_permission('attendance.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy attendance_records_delete on public.attendance_records for delete to authenticated
  using (app_private.is_super_admin() or (app_private.has_permission('attendance.delete') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));

drop policy if exists attendance_sessions_write on public.attendance_sessions;
drop policy if exists attendance_sessions_insert on public.attendance_sessions;
drop policy if exists attendance_sessions_update on public.attendance_sessions;
drop policy if exists attendance_sessions_delete on public.attendance_sessions;
create policy attendance_sessions_insert on public.attendance_sessions for insert to authenticated
  with check (app_private.is_super_admin() or (app_private.has_permission('attendance.create') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy attendance_sessions_update on public.attendance_sessions for update to authenticated
  using (app_private.is_super_admin() or (app_private.has_permission('attendance.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))))
  with check (app_private.is_super_admin() or (app_private.has_permission('attendance.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy attendance_sessions_delete on public.attendance_sessions for delete to authenticated
  using (app_private.is_super_admin() or (app_private.has_permission('attendance.delete') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));

drop policy if exists timetable_write on public.timetable_entries;
drop policy if exists timetable_insert on public.timetable_entries;
drop policy if exists timetable_update on public.timetable_entries;
drop policy if exists timetable_delete on public.timetable_entries;
create policy timetable_insert on public.timetable_entries for insert to authenticated
  with check (app_private.is_super_admin() or (app_private.has_permission('academics.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy timetable_update on public.timetable_entries for update to authenticated
  using (app_private.is_super_admin() or (app_private.has_permission('academics.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))))
  with check (app_private.is_super_admin() or (app_private.has_permission('academics.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy timetable_delete on public.timetable_entries for delete to authenticated
  using (app_private.is_super_admin() or (app_private.has_permission('academics.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
