-- Phase 2: server-side RBAC administration functions
create or replace function public.admin_create_role(
  p_name text,p_slug text,p_description text default null,p_permission_keys text[] default '{}'
) returns uuid language plpgsql security definer set search_path=public,app_private as $$
declare rid uuid;
begin
  if not app_private.has_permission('roles.create') then raise exception 'Forbidden'; end if;
  insert into public.roles(name,slug,description,institution_id,is_system)
  values(p_name,p_slug,p_description,(select institution_id from public.profiles where id=auth.uid()),false)
  returning id into rid;
  insert into public.role_permissions(role_id,permission_id)
  select rid,p.id from public.permissions p where p.key=any(p_permission_keys) on conflict do nothing;
  insert into public.audit_logs(institution_id,actor_user_id,action,entity_type,entity_id,metadata)
  select pr.institution_id,auth.uid(),'role.created','role',rid::text,jsonb_build_object('slug',p_slug)
  from public.profiles pr where pr.id=auth.uid();
  return rid;
end $$;

create or replace function public.admin_assign_role(p_user_id uuid,p_role_id uuid)
returns void language plpgsql security definer set search_path=public,app_private as $$
declare inst uuid;
begin
  if not app_private.has_permission('roles.edit') then raise exception 'Forbidden'; end if;
  select institution_id into inst from public.profiles where id=auth.uid();
  if exists(select 1 from public.roles r where r.id=p_role_id and r.is_system and r.slug='super-admin') and not app_private.is_super_admin() then raise exception 'Only Super Admin may assign Super Admin'; end if;
  if not exists(select 1 from public.profiles where id=p_user_id and institution_id=inst) then raise exception 'User outside institution'; end if;
  if not exists(select 1 from public.roles where id=p_role_id and (institution_id=inst or institution_id is null)) then raise exception 'Role outside institution'; end if;
  insert into public.user_roles(user_id,role_id) values(p_user_id,p_role_id) on conflict do nothing;
  insert into public.audit_logs(institution_id,actor_user_id,action,entity_type,entity_id,metadata) values(inst,auth.uid(),'user.role_assigned','profile',p_user_id::text,jsonb_build_object('role_id',p_role_id));
end $$;

create or replace function public.admin_assign_branch(p_user_id uuid,p_branch_id uuid)
returns void language plpgsql security definer set search_path=public,app_private as $$
declare inst uuid;
begin
  if not app_private.has_permission('users.edit') then raise exception 'Forbidden'; end if;
  select institution_id into inst from public.profiles where id=auth.uid();
  if not exists(select 1 from public.branches where id=p_branch_id and institution_id=inst) then raise exception 'Branch outside institution'; end if;
  if not exists(select 1 from public.profiles where id=p_user_id and institution_id=inst) then raise exception 'User outside institution'; end if;
  insert into public.user_branches(user_id,branch_id) values(p_user_id,p_branch_id) on conflict do nothing;
  insert into public.audit_logs(institution_id,actor_user_id,action,entity_type,entity_id,branch_id,metadata) values(inst,auth.uid(),'user.branch_assigned','profile',p_user_id::text,p_branch_id,jsonb_build_object('branch_id',p_branch_id));
end $$;
revoke all on function public.admin_create_role(text,text,text,text[]) from public,anon;
revoke all on function public.admin_assign_role(uuid,uuid) from public,anon;
revoke all on function public.admin_assign_branch(uuid,uuid) from public,anon;
grant execute on function public.admin_create_role(text,text,text,text[]) to authenticated;
grant execute on function public.admin_assign_role(uuid,uuid) to authenticated;
grant execute on function public.admin_assign_branch(uuid,uuid) to authenticated;