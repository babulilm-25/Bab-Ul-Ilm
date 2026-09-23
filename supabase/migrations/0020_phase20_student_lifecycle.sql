-- Phase 20: student lifecycle enrollment
create table if not exists public.student_enrollments (
 id uuid primary key default gen_random_uuid(),
 institution_id uuid not null references public.institutions(id) on delete cascade,
 student_id uuid not null references public.students(id) on delete cascade,
 academic_year_id uuid references public.academic_years(id) on delete set null,
 class_id uuid not null references public.academic_classes(id) on delete restrict,
 section_id uuid references public.sections(id) on delete set null,
 roll_no text,
 status text not null default 'active' check(status in ('active','completed','withdrawn','transferred')),
 enrolled_on date not null default current_date,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create index if not exists student_enrollments_institution_student_idx on public.student_enrollments(institution_id,student_id);
create index if not exists student_enrollments_class_section_idx on public.student_enrollments(class_id,section_id);
create unique index if not exists student_enrollments_active_student_year_uidx on public.student_enrollments(student_id,academic_year_id) where status='active' and academic_year_id is not null;
alter table public.student_enrollments enable row level security;
drop policy if exists student_enrollments_select on public.student_enrollments;
drop policy if exists student_enrollments_insert on public.student_enrollments;
drop policy if exists student_enrollments_update on public.student_enrollments;
drop policy if exists student_enrollments_delete on public.student_enrollments;
create policy student_enrollments_select on public.student_enrollments for select to authenticated using (app_private.is_super_admin() or (institution_id=(select institution_id from public.profiles where id=(select auth.uid())) and app_private.has_permission('students.view')));
create policy student_enrollments_insert on public.student_enrollments for insert to authenticated with check (app_private.is_super_admin() or (institution_id=(select institution_id from public.profiles where id=(select auth.uid())) and app_private.has_permission('students.create')));
create policy student_enrollments_update on public.student_enrollments for update to authenticated using (app_private.is_super_admin() or (institution_id=(select institution_id from public.profiles where id=(select auth.uid())) and app_private.has_permission('students.edit'))) with check (app_private.is_super_admin() or (institution_id=(select institution_id from public.profiles where id=(select auth.uid())) and app_private.has_permission('students.edit')));
create policy student_enrollments_delete on public.student_enrollments for delete to authenticated using (app_private.is_super_admin() or (institution_id=(select institution_id from public.profiles where id=(select auth.uid())) and app_private.has_permission('students.delete')));
create trigger student_enrollments_updated_at before update on public.student_enrollments for each row execute function public.touch_updated_at();