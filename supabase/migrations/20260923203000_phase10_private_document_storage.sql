-- Phase 10: private document storage foundation
insert into storage.buckets(id,name,public) values('documents','documents',false)
on conflict (id) do update set public=false;

drop policy if exists "documents_select_institution" on storage.objects;
drop policy if exists "documents_insert_institution" on storage.objects;
drop policy if exists "documents_update_institution" on storage.objects;
drop policy if exists "documents_delete_institution" on storage.objects;

create policy "documents_select_institution" on storage.objects for select to authenticated using (
 bucket_id='documents' and exists(select 1 from public.profiles p where p.id=auth.uid() and p.institution_id::text=split_part(name,'/',1))
);
create policy "documents_insert_institution" on storage.objects for insert to authenticated with check (
 bucket_id='documents' and exists(select 1 from public.profiles p where p.id=auth.uid() and p.institution_id::text=split_part(name,'/',1) and (app_private.is_super_admin() or app_private.has_permission('students.edit') or app_private.has_permission('teachers.edit') or app_private.has_permission('settings.edit')))
);
create policy "documents_update_institution" on storage.objects for update to authenticated using (
 bucket_id='documents' and exists(select 1 from public.profiles p where p.id=auth.uid() and p.institution_id::text=split_part(name,'/',1) and (app_private.is_super_admin() or app_private.has_permission('students.edit') or app_private.has_permission('teachers.edit') or app_private.has_permission('settings.edit')))
) with check (
 bucket_id='documents' and exists(select 1 from public.profiles p where p.id=auth.uid() and p.institution_id::text=split_part(name,'/',1) and (app_private.is_super_admin() or app_private.has_permission('students.edit') or app_private.has_permission('teachers.edit') or app_private.has_permission('settings.edit')))
);
create policy "documents_delete_institution" on storage.objects for delete to authenticated using (
 bucket_id='documents' and exists(select 1 from public.profiles p where p.id=auth.uid() and p.institution_id::text=split_part(name,'/',1) and app_private.is_super_admin())
);