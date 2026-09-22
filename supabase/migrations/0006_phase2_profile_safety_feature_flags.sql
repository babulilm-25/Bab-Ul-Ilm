-- Phase 2: profile safety and provider-dependent feature flags
create or replace function public.complete_password_change(p_password_changed_at timestamptz default now())
returns void language plpgsql security invoker set search_path=public
as $$
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  update public.profiles set must_change_password=false, updated_at=coalesce(p_password_changed_at,now()) where id=auth.uid();
end;
$$;
revoke all on function public.complete_password_change(timestamptz) from public,anon;
grant execute on function public.complete_password_change(timestamptz) to authenticated;

drop policy if exists profiles_self_update on public.profiles;
create policy profiles_self_update on public.profiles for update to authenticated
using (id=auth.uid() or (select app_private.is_super_admin()))
with check (id=auth.uid() or (select app_private.is_super_admin()));

revoke update on public.profiles from authenticated;
grant update (display_name,phone,avatar_path,locale,theme) on public.profiles to authenticated;

insert into public.app_settings(institution_id,key,value)
select i.id,'feature.online_payments',jsonb_build_object('enabled',false,'status','disabled_until_integration')
from public.institutions i
on conflict(institution_id,key) do nothing;

insert into public.app_settings(institution_id,key,value)
select i.id,'feature.sms_notifications',jsonb_build_object('enabled',false,'status','disabled_until_provider_setup')
from public.institutions i
on conflict(institution_id,key) do nothing;
