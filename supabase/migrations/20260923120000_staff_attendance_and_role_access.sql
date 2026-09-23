-- Add exam permissions used by the exam/results UI
insert into public.permissions(key,module,description) values
('exams.view','exams','View exams and results'),
('exams.create','exams','Create exams and results'),
('exams.edit','exams','Edit exams and results'),
('exams.delete','exams','Delete exams and results')
on conflict (key) do nothing;

-- Staff attendance + role access hardening
create table if not exists public.staff_attendance (
 id uuid primary key default gen_random_uuid(),
 institution_id uuid not null references public.institutions(id) on delete cascade,
 staff_id uuid not null references public.staff(id) on delete cascade,
 attendance_date date not null,
 status text not null default 'present' check (status in ('present','absent','late','leave')),
 remarks text,
 recorded_by uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(institution_id, staff_id, attendance_date)
);
alter table public.staff_attendance enable row level security;
grant select, insert, update, delete on public.staff_attendance to authenticated;
drop trigger if exists staff_attendance_touch_updated_at on public.staff_attendance;
create trigger staff_attendance_touch_updated_at before update on public.staff_attendance for each row execute function public.touch_updated_at();
create index if not exists staff_attendance_institution_date_idx on public.staff_attendance(institution_id, attendance_date desc);
create index if not exists staff_attendance_staff_date_idx on public.staff_attendance(staff_id, attendance_date desc);
drop policy if exists staff_attendance_select on public.staff_attendance;
drop policy if exists staff_attendance_insert on public.staff_attendance;
drop policy if exists staff_attendance_update on public.staff_attendance;
drop policy if exists staff_attendance_delete on public.staff_attendance;
create policy staff_attendance_select on public.staff_attendance for select to authenticated using (app_private.is_super_admin() or (app_private.has_permission('attendance.view') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy staff_attendance_insert on public.staff_attendance for insert to authenticated with check (app_private.is_super_admin() or (app_private.has_permission('attendance.create') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy staff_attendance_update on public.staff_attendance for update to authenticated using (app_private.is_super_admin() or (app_private.has_permission('attendance.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid())))) with check (app_private.is_super_admin() or (app_private.has_permission('attendance.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy staff_attendance_delete on public.staff_attendance for delete to authenticated using (app_private.is_super_admin() or (app_private.has_permission('attendance.delete') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));

insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from public.roles r cross join public.permissions p
where r.slug='super-admin' on conflict do nothing;
with role_keys(slug,keys) as (
 values
 ('admin',array['exams.view','exams.create','exams.edit','exams.delete','dashboard.view','users.view','users.create','users.edit','users.disable','students.view','students.create','students.edit','students.archive','students.export','academics.view','academics.edit','teachers.view','teachers.create','teachers.edit','attendance.view','attendance.create','attendance.edit','exams.view','exams.create','exams.edit','fees.view','fees.create','fees.edit','finance.view','finance.create','finance.edit','finance.export','library.view','library.create','library.edit','inventory.view','inventory.create','inventory.edit','reports.view','reports.create','reports.export','audit.view','settings.view']),
 ('hr',array['dashboard.view','teachers.view','teachers.create','teachers.edit','attendance.view','attendance.create','attendance.edit','reports.view','reports.export']),
 ('teacher',array['exams.view','exams.create','exams.edit','dashboard.view','academics.view','students.view','teachers.view','attendance.view','attendance.create','attendance.edit','exams.view','exams.create','exams.edit','reports.view','reports.export']),
 ('accountant',array['dashboard.view','students.view','fees.view','fees.create','fees.edit','finance.view','finance.create','finance.edit','finance.export','reports.view','reports.export']),
 ('librarian',array['dashboard.view','students.view','library.view','library.create','library.edit','library.delete','reports.view','reports.export']),
 ('storekeeper',array['dashboard.view','inventory.view','inventory.create','inventory.edit','inventory.delete','reports.view','reports.export']),
 ('staff',array['dashboard.view','attendance.view','attendance.create','reports.view']),
 ('warden',array['dashboard.view','students.view','attendance.view','reports.view']),
 ('student',array['dashboard.view','attendance.view','reports.view']),
 ('parent',array['dashboard.view','attendance.view','reports.view'])
)
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from role_keys rk join public.roles r on r.slug=rk.slug cross join lateral unnest(rk.keys) k(key) join public.permissions p on p.key=k.key on conflict do nothing;