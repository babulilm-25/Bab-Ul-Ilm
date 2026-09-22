-- Phase 2: split RLS policies to avoid overlapping permissive SELECT policies
drop policy if exists branches_manage on public.branches;
create policy branches_insert on public.branches for insert to authenticated with check((select app_private.is_super_admin()));
create policy branches_update on public.branches for update to authenticated using((select app_private.is_super_admin())) with check((select app_private.is_super_admin()));
create policy branches_delete on public.branches for delete to authenticated using((select app_private.is_super_admin()));
drop policy if exists roles_manage on public.roles;
create policy roles_insert on public.roles for insert to authenticated with check((select app_private.is_super_admin()) or (select app_private.has_permission('roles.edit')));
create policy roles_update on public.roles for update to authenticated using((select app_private.is_super_admin()) or (select app_private.has_permission('roles.edit'))) with check((select app_private.is_super_admin()) or (select app_private.has_permission('roles.edit')));
create policy roles_delete on public.roles for delete to authenticated using((select app_private.is_super_admin()) or (select app_private.has_permission('roles.delete')));
drop policy if exists academic_years_manage on public.academic_years;
create policy academic_years_insert on public.academic_years for insert to authenticated with check((select app_private.is_super_admin()) or (select app_private.has_permission('academics.edit')));
create policy academic_years_update on public.academic_years for update to authenticated using((select app_private.is_super_admin()) or (select app_private.has_permission('academics.edit'))) with check((select app_private.is_super_admin()) or (select app_private.has_permission('academics.edit')));
create policy academic_years_delete on public.academic_years for delete to authenticated using((select app_private.is_super_admin()) or (select app_private.has_permission('academics.edit')));