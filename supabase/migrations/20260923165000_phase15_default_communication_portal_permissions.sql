-- Phase 15: grant communication and portal management to institution Admin
insert into public.role_permissions(role_id, permission_id)
select r.id, p.id
from public.roles r
cross join public.permissions p
where r.slug='admin'
  and p.key in (
    'communication.view','communication.create','communication.edit',
    'portal.view','portal.create','portal.edit'
  )
on conflict do nothing;
