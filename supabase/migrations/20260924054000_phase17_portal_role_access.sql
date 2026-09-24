-- Phase 17: portal access defaults
-- Student and Parent roles need portal.view for self-service portal access.
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id
from public.roles r
cross join public.permissions p
where r.slug in ('student','parent')
  and p.key='portal.view'
on conflict do nothing;
