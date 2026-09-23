-- Phase 5: database performance hardening for newly added foreign keys and auth RLS.
create index if not exists academic_terms_institution_idx on public.academic_terms(institution_id);
create index if not exists admissions_branch_idx on public.admissions(branch_id);
create index if not exists buildings_campus_idx on public.buildings(campus_id);
create index if not exists campuses_branch_idx on public.campuses(branch_id);
create index if not exists login_events_institution_idx on public.login_events(institution_id);
create index if not exists org_units_department_idx on public.org_units(department_id);
create index if not exists org_units_parent_idx on public.org_units(parent_id);
create index if not exists staff_attendance_recorded_by_idx on public.staff_attendance(recorded_by);
create index if not exists students_academic_year_idx on public.students(academic_year_id);
create index if not exists students_section_idx on public.students(section_id);

drop policy if exists login_events_insert on public.login_events;
drop policy if exists login_events_select on public.login_events;
create policy login_events_insert on public.login_events for insert to authenticated with check ((select auth.uid()) = user_id);
create policy login_events_select on public.login_events for select to authenticated using ((select auth.uid()) = user_id or app_private.institution_permission(institution_id,'audit.view'));
