-- Phase 4: granular hostel/mess/library/inventory authorization
-- Keep module access separate from the generic student permission used by the Phase 3 foundation.
insert into public.permissions(key,description,module) values
 ('hostel.view','View hostel buildings, rooms, beds, allocations and attendance','hostel'),
 ('hostel.create','Create hostel records and allocations','hostel'),
 ('hostel.edit','Edit hostel records and allocations','hostel'),
 ('hostel.delete','Delete hostel records','hostel'),
 ('mess.view','View mess plans, menus and attendance','mess'),
 ('mess.create','Create mess plans, menus and attendance','mess'),
 ('mess.edit','Edit mess plans, menus and attendance','mess'),
 ('mess.delete','Delete mess records','mess')
on conflict (key) do nothing;

-- Replace the Phase 3 broad students.* policies with module-specific authorization.
do $$ declare t text; p text; begin
 foreach t in array array['hostel_buildings','hostel_rooms','hostel_beds','hostel_allocations','hostel_attendance'] loop
  execute format('drop policy if exists %I_select on public.%I',t,t);
  execute format('drop policy if exists %I_write on public.%I',t,t);
  execute format('create policy %I_select on public.%I for select to authenticated using(app_private.institution_permission(institution_id,''hostel.view''))',t,t);
  execute format('create policy %I_insert on public.%I for insert to authenticated with check(app_private.institution_permission(institution_id,''hostel.create''))',t,t);
  execute format('create policy %I_update on public.%I for update to authenticated using(app_private.institution_permission(institution_id,''hostel.edit'')) with check(app_private.institution_permission(institution_id,''hostel.edit''))',t,t);
  execute format('create policy %I_delete on public.%I for delete to authenticated using(app_private.institution_permission(institution_id,''hostel.delete''))',t,t);
 end loop;
 foreach t in array array['mess_meal_plans','mess_menus','mess_attendance'] loop
  execute format('drop policy if exists %I_select on public.%I',t,t);
  execute format('drop policy if exists %I_write on public.%I',t,t);
  execute format('create policy %I_select on public.%I for select to authenticated using(app_private.institution_permission(institution_id,''mess.view''))',t,t);
  execute format('create policy %I_insert on public.%I for insert to authenticated with check(app_private.institution_permission(institution_id,''mess.create''))',t,t);
  execute format('create policy %I_update on public.%I for update to authenticated using(app_private.institution_permission(institution_id,''mess.edit'')) with check(app_private.institution_permission(institution_id,''mess.edit''))',t,t);
  execute format('create policy %I_delete on public.%I for delete to authenticated using(app_private.institution_permission(institution_id,''mess.delete''))',t,t);
 end loop;
 foreach t in array array['inventory_categories','inventory_suppliers'] loop
  execute format('drop policy if exists %I_select on public.%I',t,t);
  execute format('drop policy if exists %I_write on public.%I',t,t);
  execute format('create policy %I_select on public.%I for select to authenticated using(app_private.institution_permission(institution_id,''inventory.view''))',t,t);
  execute format('create policy %I_insert on public.%I for insert to authenticated with check(app_private.institution_permission(institution_id,''inventory.create''))',t,t);
  execute format('create policy %I_update on public.%I for update to authenticated using(app_private.institution_permission(institution_id,''inventory.edit'')) with check(app_private.institution_permission(institution_id,''inventory.edit''))',t,t);
  execute format('create policy %I_delete on public.%I for delete to authenticated using(app_private.institution_permission(institution_id,''inventory.delete''))',t,t);
 end loop;
 foreach t in array array['library_book_copies'] loop
  execute format('drop policy if exists %I_select on public.%I',t,t);
  execute format('drop policy if exists %I_write on public.%I',t,t);
  execute format('create policy %I_select on public.%I for select to authenticated using(app_private.institution_permission(institution_id,''library.view''))',t,t);
  execute format('create policy %I_insert on public.%I for insert to authenticated with check(app_private.institution_permission(institution_id,''library.create''))',t,t);
  execute format('create policy %I_update on public.%I for update to authenticated using(app_private.institution_permission(institution_id,''library.edit'')) with check(app_private.institution_permission(institution_id,''library.edit''))',t,t);
  execute format('create policy %I_delete on public.%I for delete to authenticated using(app_private.institution_permission(institution_id,''library.delete''))',t,t);
 end loop;
end $$;

-- Give operational roles only the modules they are responsible for; Super Admin remains unrestricted.
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from public.roles r cross join public.permissions p
where r.slug in ('admin','warden') and p.key like 'hostel.%' on conflict do nothing;
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from public.roles r cross join public.permissions p
where r.slug in ('admin','warden') and p.key like 'mess.%' on conflict do nothing;
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from public.roles r cross join public.permissions p
where r.slug in ('admin','librarian') and p.key like 'library.%' on conflict do nothing;
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from public.roles r cross join public.permissions p
where r.slug in ('admin','storekeeper') and p.key like 'inventory.%' on conflict do nothing;
