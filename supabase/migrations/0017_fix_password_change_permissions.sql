-- Phase 20: secure first-login password completion
create or replace function app_private.complete_password_change()
returns void
language plpgsql
security definer
set search_path = public, app_private
as $$
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  update public.profiles set must_change_password=false, updated_at=now() where id=auth.uid();
  if not found then raise exception 'Profile not found'; end if;
end;
$$;
revoke all on function app_private.complete_password_change() from public, anon, authenticated;
grant execute on function app_private.complete_password_change() to authenticated;

create or replace function public.complete_password_change()
returns void
language plpgsql
security invoker
set search_path = public, app_private
as $$ begin perform app_private.complete_password_change(); end; $$;
revoke all on function public.complete_password_change() from public, anon, authenticated;
grant execute on function public.complete_password_change() to authenticated;
