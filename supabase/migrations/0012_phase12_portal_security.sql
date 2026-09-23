-- Phase 12: Parent / Student portal security and communication automation

create or replace function app_private.portal_has_student_access(target_student uuid, uid uuid default auth.uid())
returns boolean
language sql stable security definer
set search_path = public, app_private
as $$
  select exists (
    select 1 from public.portal_profiles pp
    where pp.user_id = coalesce(uid, auth.uid())
      and pp.student_id = target_student
      and pp.active = true
  );
$$;

create or replace function app_private.portal_is_active(uid uuid default auth.uid())
returns boolean
language sql stable security definer
set search_path = public, app_private
as $$
  select exists (
    select 1 from public.portal_profiles pp
    where pp.user_id = coalesce(uid, auth.uid())
      and pp.active = true
  );
$$;

revoke all on function app_private.portal_has_student_access(uuid, uuid) from public, anon, authenticated;
revoke all on function app_private.portal_is_active(uuid) from public, anon, authenticated;

create index if not exists portal_profiles_active_user_student_idx
  on public.portal_profiles (user_id, student_id) where active = true;
create index if not exists notifications_unread_user_idx
  on public.notifications (user_id, created_at desc) where read_at is null;

drop policy if exists students_portal_select on public.students;
drop policy if exists students_select on public.students;
create policy students_select on public.students for select to authenticated
using (
  app_private.portal_has_student_access(id)
  or (
    app_private.has_permission('students.view')
    and (app_private.is_super_admin() or institution_id = (select profiles.institution_id from public.profiles where profiles.id = (select auth.uid())))
  )
);

drop policy if exists attendance_records_portal_select on public.attendance_records;
drop policy if exists attendance_records_select on public.attendance_records;
create policy attendance_records_select on public.attendance_records for select to public
using (
  app_private.portal_has_student_access(student_id)
  or app_private.is_super_admin()
  or (
    app_private.has_permission('attendance.view')
    and institution_id = (select profiles.institution_id from public.profiles where profiles.id = (select auth.uid()))
  )
);

drop policy if exists student_fee_assignments_portal_select on public.student_fee_assignments;
drop policy if exists fee_assignments_select on public.student_fee_assignments;
create policy fee_assignments_select on public.student_fee_assignments for select to authenticated
using (
  app_private.portal_has_student_access(student_id)
  or (
    institution_id = (select profiles.institution_id from public.profiles where profiles.id = (select auth.uid()))
    and (app_private.has_permission('fees.view') or app_private.has_permission('finance.view') or app_private.is_super_admin())
  )
);

drop policy if exists fee_payments_portal_select on public.fee_payments;
drop policy if exists fee_payments_select on public.fee_payments;
create policy fee_payments_select on public.fee_payments for select to authenticated
using (
  app_private.portal_has_student_access(student_id)
  or (
    institution_id = (select profiles.institution_id from public.profiles where profiles.id = (select auth.uid()))
    and (app_private.has_permission('fees.view') or app_private.has_permission('finance.view') or app_private.is_super_admin())
  )
);

drop policy if exists exam_results_portal_select on public.exam_results;
drop policy if exists exam_results_select on public.exam_results;
create policy exam_results_select on public.exam_results for select to authenticated
using (
  app_private.portal_has_student_access(student_id)
  or (
    institution_id = (select profiles.institution_id from public.profiles where profiles.id = (select auth.uid()))
    and (app_private.has_permission('academics.view') or app_private.is_super_admin())
  )
);

drop policy if exists student_certificates_portal_select on public.student_certificates;
drop policy if exists student_certificates_select on public.student_certificates;
create policy student_certificates_select on public.student_certificates for select to authenticated
using (
  app_private.portal_has_student_access(student_id)
  or (
    institution_id = (select profiles.institution_id from public.profiles where profiles.id = (select auth.uid()))
    and (app_private.has_permission('reports.view') or app_private.is_super_admin())
  )
);

drop policy if exists generated_documents_portal_select on public.generated_documents;
drop policy if exists generated_documents_select on public.generated_documents;
create policy generated_documents_select on public.generated_documents for select to authenticated
using (
  app_private.portal_has_student_access(student_id)
  or (
    institution_id = (select profiles.institution_id from public.profiles where profiles.id = (select auth.uid()))
    and (app_private.has_permission('reports.view') or app_private.is_super_admin())
  )
);

drop policy if exists library_issues_portal_select on public.library_issues;
drop policy if exists library_issues_select on public.library_issues;
create policy library_issues_select on public.library_issues for select to authenticated
using (
  app_private.portal_has_student_access(student_id)
  or (
    institution_id = (select profiles.institution_id from public.profiles where profiles.id = (select auth.uid()))
    and (app_private.has_permission('library.view') or app_private.is_super_admin())
  )
);

drop policy if exists announcements_select on public.announcements;
create policy announcements_select on public.announcements for select to authenticated
using (
  active = true
  and (
    app_private.is_super_admin()
    or app_private.has_permission('dashboard.view')
    or (
      app_private.portal_is_active()
      and (
        audience = 'all'
        or audience = case
          when exists (select 1 from public.portal_profiles pp where pp.user_id=(select auth.uid()) and pp.active=true and pp.role_type='parent') then 'parents'
          when exists (select 1 from public.portal_profiles pp where pp.user_id=(select auth.uid()) and pp.active=true and pp.role_type='student') then 'students'
          when exists (select 1 from public.portal_profiles pp where pp.user_id=(select auth.uid()) and pp.active=true and pp.role_type='teacher') then 'teachers'
          when exists (select 1 from public.portal_profiles pp where pp.user_id=(select auth.uid()) and pp.active=true and pp.role_type='staff') then 'staff'
          else audience
        end
      )
    )
  )
);

create or replace function app_private.notify_announcement_recipients()
returns trigger
language plpgsql security definer
set search_path = public, app_private
as $$
begin
  if new.active = true and new.published_at is not null then
    insert into public.notifications (institution_id,user_id,title,message,notification_type)
    select distinct pp.institution_id,pp.user_id,new.title,new.message,'announcement'
    from public.portal_profiles pp
    where pp.institution_id=new.institution_id and pp.active=true
      and (new.audience='all' or pp.role_type=case
        when new.audience='parents' then 'parent'
        when new.audience='students' then 'student'
        when new.audience='teachers' then 'teacher'
        when new.audience='staff' then 'staff'
        else '__none__' end)
    on conflict do nothing;
  end if;
  return new;
end;
$$;

revoke all on function app_private.notify_announcement_recipients() from public, anon, authenticated;
drop trigger if exists announcement_notification_trigger on public.announcements;
create trigger announcement_notification_trigger
after insert or update of active,published_at,title,message,audience
on public.announcements for each row
execute function app_private.notify_announcement_recipients();
