-- Phase 2: security/performance hardening
create or replace function public.admin_create_role(p_name text,p_slug text,p_description text default null,p_permission_keys text[] default '{}')
returns uuid language plpgsql security invoker set search_path=public,app_private as $$ declare rid uuid; begin
if not app_private.has_permission('roles.create') then raise exception 'Forbidden'; end if;
insert into public.roles(name,slug,description,institution_id,is_system) values(p_name,p_slug,p_description,(select institution_id from public.profiles where id=(select auth.uid())),false) returning id into rid;
insert into public.role_permissions(role_id,permission_id) select rid,p.id from public.permissions p where p.key=any(p_permission_keys) on conflict do nothing; return rid; end $$;
create or replace function public.admin_assign_role(p_user_id uuid,p_role_id uuid) returns void language plpgsql security invoker set search_path=public,app_private as $$ declare inst uuid; begin
if not app_private.has_permission('roles.edit') then raise exception 'Forbidden'; end if; select institution_id into inst from public.profiles where id=(select auth.uid());
if exists(select 1 from public.roles r where r.id=p_role_id and r.is_system and r.slug='super-admin') and not app_private.is_super_admin() then raise exception 'Only Super Admin may assign Super Admin'; end if;
if not exists(select 1 from public.profiles where id=p_user_id and institution_id=inst) then raise exception 'User outside institution'; end if;
if not exists(select 1 from public.roles where id=p_role_id and (institution_id=inst or institution_id is null)) then raise exception 'Role outside institution'; end if;
insert into public.user_roles(user_id,role_id) values(p_user_id,p_role_id) on conflict do nothing; end $$;
create or replace function public.admin_assign_branch(p_user_id uuid,p_branch_id uuid) returns void language plpgsql security invoker set search_path=public,app_private as $$ declare inst uuid; begin
if not app_private.has_permission('users.edit') then raise exception 'Forbidden'; end if; select institution_id into inst from public.profiles where id=(select auth.uid());
if not exists(select 1 from public.branches where id=p_branch_id and institution_id=inst) then raise exception 'Branch outside institution'; end if;
if not exists(select 1 from public.profiles where id=p_user_id and institution_id=inst) then raise exception 'User outside institution'; end if;
insert into public.user_branches(user_id,branch_id) values(p_user_id,p_branch_id) on conflict do nothing; end $$;
drop policy if exists branches_access on public.branches; drop policy if exists branches_admin on public.branches;
create policy branches_select on public.branches for select to authenticated using((select app_private.is_super_admin()) or (select app_private.has_branch_access(id)));
create policy branches_manage on public.branches for all to authenticated using((select app_private.is_super_admin())) with check((select app_private.is_super_admin()));
drop policy if exists roles_access on public.roles; drop policy if exists roles_admin on public.roles;
create policy roles_select on public.roles for select to authenticated using((select app_private.is_super_admin()) or (select app_private.has_permission('roles.view')));
create policy roles_manage on public.roles for all to authenticated using((select app_private.is_super_admin()) or (select app_private.has_permission('roles.edit'))) with check((select app_private.is_super_admin()) or (select app_private.has_permission('roles.edit')));
drop policy if exists academic_years_access on public.academic_years; drop policy if exists academic_years_admin on public.academic_years;
create policy academic_years_select on public.academic_years for select to authenticated using((select app_private.is_super_admin()) or (select app_private.has_permission('academics.view')));
create policy academic_years_manage on public.academic_years for all to authenticated using((select app_private.is_super_admin()) or (select app_private.has_permission('academics.edit'))) with check((select app_private.is_super_admin()) or (select app_private.has_permission('academics.edit')));
drop policy if exists profiles_self_select on public.profiles; drop policy if exists profiles_self_update on public.profiles;
create policy profiles_select on public.profiles for select to authenticated using((id=(select auth.uid())) or (select app_private.is_super_admin()));
create policy profiles_update on public.profiles for update to authenticated using((id=(select auth.uid())) or (select app_private.is_super_admin())) with check((id=(select auth.uid())) or (select app_private.is_super_admin()));
drop policy if exists audit_logs_insert on public.audit_logs;
create policy audit_logs_insert on public.audit_logs for insert to authenticated with check(actor_user_id=(select auth.uid()));
create index if not exists bootstrap_state_completed_user_idx on app_private.bootstrap_state(completed_user_id);
create index if not exists academic_years_institution_idx on public.academic_years(institution_id);
create index if not exists app_settings_updated_by_idx on public.app_settings(updated_by);
create index if not exists audit_logs_actor_idx on public.audit_logs(actor_user_id);
create index if not exists audit_logs_branch_idx on public.audit_logs(branch_id);