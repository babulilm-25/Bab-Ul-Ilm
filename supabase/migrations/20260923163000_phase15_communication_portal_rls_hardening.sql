-- Phase 15: align communication and portal RLS with granular permissions
drop policy if exists announcements_insert on public.announcements;
drop policy if exists announcements_select on public.announcements;
drop policy if exists announcements_update on public.announcements;

create policy announcements_insert on public.announcements
for insert to authenticated
with check (
  institution_id = (select p.institution_id from public.profiles p where p.id = (select auth.uid()))
  and (app_private.is_super_admin() or app_private.has_permission('communication.create'))
);

create policy announcements_select on public.announcements
for select to authenticated
using (
  app_private.is_super_admin()
  or (
    institution_id = (select p.institution_id from public.profiles p where p.id = (select auth.uid()))
    and (
      app_private.has_permission('communication.view')
      or app_private.has_permission('communication.create')
      or app_private.has_permission('communication.edit')
    )
  )
  or (
    active = true
    and app_private.portal_is_active()
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
);

create policy announcements_update on public.announcements
for update to authenticated
using (
  institution_id = (select p.institution_id from public.profiles p where p.id = (select auth.uid()))
  and (app_private.is_super_admin() or app_private.has_permission('communication.edit'))
)
with check (
  institution_id = (select p.institution_id from public.profiles p where p.id = (select auth.uid()))
  and (app_private.is_super_admin() or app_private.has_permission('communication.edit'))
);

drop policy if exists portal_profiles_insert on public.portal_profiles;
drop policy if exists portal_profiles_select on public.portal_profiles;
drop policy if exists portal_profiles_update on public.portal_profiles;

create policy portal_profiles_insert on public.portal_profiles
for insert to authenticated
with check (
  (app_private.is_super_admin() or app_private.has_permission('portal.create'))
  and institution_id = (select p.institution_id from public.profiles p where p.id = (select auth.uid()))
  and exists (select 1 from public.profiles target_user where target_user.id=portal_profiles.user_id and target_user.institution_id=portal_profiles.institution_id)
  and (student_id is null or exists (select 1 from public.students s where s.id=portal_profiles.student_id and s.institution_id=portal_profiles.institution_id))
);

create policy portal_profiles_select on public.portal_profiles
for select to authenticated
using (
  user_id = (select auth.uid())
  or app_private.is_super_admin()
  or (
    institution_id = (select p.institution_id from public.profiles p where p.id = (select auth.uid()))
    and (app_private.has_permission('portal.view') or app_private.has_permission('portal.create') or app_private.has_permission('portal.edit'))
  )
);

create policy portal_profiles_update on public.portal_profiles
for update to authenticated
using (
  institution_id = (select p.institution_id from public.profiles p where p.id=(select auth.uid()))
  and (app_private.is_super_admin() or app_private.has_permission('portal.edit'))
)
with check (
  institution_id = (select p.institution_id from public.profiles p where p.id=(select auth.uid()))
  and (app_private.is_super_admin() or app_private.has_permission('portal.edit'))
);
