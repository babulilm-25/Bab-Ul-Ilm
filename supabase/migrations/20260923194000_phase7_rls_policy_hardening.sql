-- Phase 7: RLS policy hardening
-- Split broad ALL write policies into command-specific policies so SELECT
-- does not evaluate write predicates and UPDATE retains explicit WITH CHECK.

drop policy if exists academic_terms_write on public.academic_terms;
drop policy if exists buildings_write on public.buildings;
drop policy if exists campuses_write on public.campuses;
drop policy if exists departments_write on public.departments;
drop policy if exists org_units_write on public.org_units;

create policy academic_terms_insert on public.academic_terms for insert to authenticated
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('academics.edit')));
create policy academic_terms_update on public.academic_terms for update to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('academics.edit')))
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('academics.edit')));
create policy academic_terms_delete on public.academic_terms for delete to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('academics.edit')));

create policy buildings_insert on public.buildings for insert to authenticated
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));
create policy buildings_update on public.buildings for update to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')))
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));
create policy buildings_delete on public.buildings for delete to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));

create policy campuses_insert on public.campuses for insert to authenticated
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));
create policy campuses_update on public.campuses for update to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')))
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));
create policy campuses_delete on public.campuses for delete to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));

create policy departments_insert on public.departments for insert to authenticated
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));
create policy departments_update on public.departments for update to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')))
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));
create policy departments_delete on public.departments for delete to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));

create policy org_units_insert on public.org_units for insert to authenticated
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));
create policy org_units_update on public.org_units for update to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')))
  with check (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));
create policy org_units_delete on public.org_units for delete to authenticated
  using (app_private.is_super_admin() or (app_private.same_institution(institution_id) and app_private.has_permission('settings.edit')));
