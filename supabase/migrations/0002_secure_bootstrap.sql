-- Phase 2: secure Super Admin bootstrap
create table if not exists app_private.bootstrap_state (
  id boolean primary key default true check (id),
  attempts integer not null default 0 check (attempts >= 0),
  completed_at timestamptz,
  completed_user_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
insert into app_private.bootstrap_state(id) values(true) on conflict(id) do nothing;

create or replace function public.bootstrap_claim()
returns jsonb language plpgsql security definer set search_path=public,app_private
as $$
declare s app_private.bootstrap_state%rowtype;
begin
  select * into s from app_private.bootstrap_state where id=true for update;
  if s.completed_at is not null then return jsonb_build_object('allowed',false,'reason','completed'); end if;
  if s.attempts >= 5 then return jsonb_build_object('allowed',false,'reason','locked'); end if;
  update app_private.bootstrap_state set attempts=attempts+1 where id=true;
  return jsonb_build_object('allowed',true,'attempt',s.attempts+1);
end;
$$;

create or replace function public.bootstrap_finalize(target_user_id uuid, target_email text)
returns jsonb language plpgsql security definer set search_path=public,app_private
as $$
declare state app_private.bootstrap_state%rowtype; inst_id uuid; branch_id uuid; role_id uuid;
begin
  select * into state from app_private.bootstrap_state where id=true for update;
  if state.completed_at is not null then raise exception 'Bootstrap has already been completed'; end if;

  insert into public.institutions(name,legal_name,slug,default_language,timezone,currency)
  values('Madarsa Ahle Sunnat Bab UL Ilm Raza E Mustafa','Madarsa Ahle Sunnat Bab UL Ilm Raza E Mustafa','bab-ul-ilm','en','Asia/Kolkata','INR')
  on conflict(slug) do update set name=excluded.name
  returning id into inst_id;

  insert into public.branches(institution_id,name,code)
  values(inst_id,'Main Branch','MAIN')
  on conflict(institution_id,code) do update set name=excluded.name
  returning id into branch_id;

  update public.profiles
    set institution_id=inst_id, display_name='Super Admin', must_change_password=true, updated_at=now()
  where id=target_user_id;

  select id into role_id from public.roles where institution_id is null and slug='super-admin' limit 1;
  if role_id is null then raise exception 'Super Admin system role is missing'; end if;

  insert into public.user_roles(user_id,role_id) values(target_user_id,role_id) on conflict do nothing;
  insert into public.user_branches(user_id,branch_id) values(target_user_id,branch_id) on conflict do nothing;
  insert into public.app_settings(institution_id,key,value,updated_by)
  values(inst_id,'bootstrap.completed',jsonb_build_object('email',target_email,'completed_at',now()),target_user_id)
  on conflict(institution_id,key) do update set value=excluded.value,updated_by=excluded.updated_by,updated_at=now();

  insert into public.audit_logs(institution_id,actor_user_id,action,entity_type,entity_id,branch_id,metadata)
  values(inst_id,target_user_id,'bootstrap.completed','institution',inst_id::text,branch_id,jsonb_build_object('email',target_email));

  update app_private.bootstrap_state set completed_at=now(),completed_user_id=target_user_id where id=true;
  return jsonb_build_object('institution_id',inst_id,'branch_id',branch_id,'user_id',target_user_id);
end;
$$;

revoke all on function public.bootstrap_claim() from public,anon,authenticated;
revoke all on function public.bootstrap_finalize(uuid,text) from public,anon,authenticated;
grant execute on function public.bootstrap_claim() to service_role;
grant execute on function public.bootstrap_finalize(uuid,text) to service_role;
