-- Phase 3: Students, guardians and admissions
create table if not exists public.students (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete restrict,
 admission_no text not null, roll_no text, first_name text not null, middle_name text, last_name text, preferred_name text,
 gender text check (gender in ('male','female','other')), date_of_birth date, phone text, email text,
 address jsonb not null default '{}'::jsonb, guardian_name text, guardian_phone text, guardian_relation text,
 photo_path text, status text not null default 'active' check (status in ('active','inactive','graduated','transferred','withdrawn','archived')),
 joined_on date, notes text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(institution_id, admission_no)
);
create table if not exists public.student_guardians (
 id uuid primary key default gen_random_uuid(), student_id uuid not null references public.students(id) on delete cascade,
 full_name text not null, relation text not null, phone text, email text, occupation text, is_primary boolean not null default false,
 created_at timestamptz not null default now(), unique(student_id, phone)
);
create table if not exists public.admissions (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete restrict,
 student_id uuid references public.students(id) on delete set null, application_no text not null, applied_on date not null default current_date,
 status text not null default 'pending' check (status in ('pending','approved','rejected','waitlisted','cancelled','converted')),
 program text, class_name text, source text, remarks text, reviewed_by uuid references auth.users(id) on delete set null,
 reviewed_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(institution_id, application_no)
);
create index if not exists students_institution_status_idx on public.students(institution_id,status);
create index if not exists students_institution_name_idx on public.students(institution_id,first_name,last_name);
create index if not exists student_guardians_student_idx on public.student_guardians(student_id);
create index if not exists admissions_institution_status_idx on public.admissions(institution_id,status);
create index if not exists admissions_student_idx on public.admissions(student_id);
create index if not exists admissions_reviewed_by_idx on public.admissions(reviewed_by);
alter table public.students enable row level security; alter table public.student_guardians enable row level security; alter table public.admissions enable row level security;
create policy students_select on public.students for select to authenticated using ((select app_private.has_permission('students.view')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy students_insert on public.students for insert to authenticated with check ((select app_private.has_permission('students.create')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy students_update on public.students for update to authenticated using ((select app_private.has_permission('students.edit')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid())))) with check ((select app_private.has_permission('students.edit')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy students_delete on public.students for delete to authenticated using ((select app_private.has_permission('students.delete')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy guardians_select on public.student_guardians for select to authenticated using ((select app_private.has_permission('students.view')) and exists(select 1 from public.students s where s.id=student_id and ((select app_private.is_super_admin()) or s.institution_id=(select institution_id from public.profiles where id=(select auth.uid())))));
create policy guardians_insert on public.student_guardians for insert to authenticated with check ((select app_private.has_permission('students.create')) and exists(select 1 from public.students s where s.id=student_id and ((select app_private.is_super_admin()) or s.institution_id=(select institution_id from public.profiles where id=(select auth.uid())))));
create policy guardians_update on public.student_guardians for update to authenticated using ((select app_private.has_permission('students.edit')) and exists(select 1 from public.students s where s.id=student_id and ((select app_private.is_super_admin()) or s.institution_id=(select institution_id from public.profiles where id=(select auth.uid()))))) with check ((select app_private.has_permission('students.edit')) and exists(select 1 from public.students s where s.id=student_id and ((select app_private.is_super_admin()) or s.institution_id=(select institution_id from public.profiles where id=(select auth.uid())))));
create policy guardians_delete on public.student_guardians for delete to authenticated using ((select app_private.has_permission('students.delete')) and exists(select 1 from public.students s where s.id=student_id and ((select app_private.is_super_admin()) or s.institution_id=(select institution_id from public.profiles where id=(select auth.uid())))));
create policy admissions_select on public.admissions for select to authenticated using ((select app_private.has_permission('students.view')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy admissions_insert on public.admissions for insert to authenticated with check ((select app_private.has_permission('students.create')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy admissions_update on public.admissions for update to authenticated using ((select app_private.has_permission('students.edit')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid())))) with check ((select app_private.has_permission('students.edit')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy admissions_delete on public.admissions for delete to authenticated using ((select app_private.has_permission('students.delete')) and ((select app_private.is_super_admin()) or institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
