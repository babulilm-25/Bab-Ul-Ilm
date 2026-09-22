-- Phase 2: remove overlapping profile UPDATE policy and cache auth.uid() in RLS
drop policy if exists profiles_update on public.profiles;
drop policy if exists profiles_self_update on public.profiles;
create policy profiles_self_update on public.profiles for update to authenticated
using ((id=(select auth.uid())) or (select app_private.is_super_admin()))
with check ((id=(select auth.uid())) or (select app_private.is_super_admin()));
