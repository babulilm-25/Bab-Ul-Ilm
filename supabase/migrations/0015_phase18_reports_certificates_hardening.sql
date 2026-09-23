-- Phase 18: reports and certificates hardening
create unique index if not exists student_certificates_institution_no_uidx
  on public.student_certificates(institution_id, certificate_no)
  where certificate_no is not null and certificate_no <> '';
create unique index if not exists generated_documents_institution_no_uidx
  on public.generated_documents(institution_id, document_no)
  where document_no is not null and document_no <> '';
create index if not exists student_certificates_student_date_idx
  on public.student_certificates(student_id, issue_date desc);
create index if not exists generated_documents_student_date_idx
  on public.generated_documents(student_id, issued_on desc);

drop policy if exists generated_documents_write on public.generated_documents;
drop policy if exists report_templates_write on public.report_templates;
drop policy if exists student_certificates_write on public.student_certificates;

create policy generated_documents_insert on public.generated_documents for insert to authenticated
with check ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()));
create policy generated_documents_update on public.generated_documents for update to authenticated
using ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()))
with check ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()));
create policy generated_documents_delete on public.generated_documents for delete to authenticated
using ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()));

create policy report_templates_insert on public.report_templates for insert to authenticated
with check ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()));
create policy report_templates_update on public.report_templates for update to authenticated
using ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()))
with check ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()));
create policy report_templates_delete on public.report_templates for delete to authenticated
using ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()));

create policy student_certificates_insert on public.student_certificates for insert to authenticated
with check ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()));
create policy student_certificates_update on public.student_certificates for update to authenticated
using ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()))
with check ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()));
create policy student_certificates_delete on public.student_certificates for delete to authenticated
using ((institution_id=(select institution_id from public.profiles where id=(select auth.uid()))) and (app_private.has_permission('reports.create') or app_private.is_super_admin()));

-- Normalize remaining write policies flagged by the performance advisor.
drop policy if exists staff_documents_write on public.staff_documents;
drop policy if exists teacher_classes_write on public.teacher_classes;
drop policy if exists teacher_subjects_write on public.teacher_subjects;
create policy staff_documents_insert on public.staff_documents for insert to authenticated with check (app_private.is_super_admin() or (app_private.has_permission('teachers.create') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy staff_documents_update on public.staff_documents for update to authenticated using (app_private.is_super_admin() or (app_private.has_permission('teachers.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid())))) with check (app_private.is_super_admin() or (app_private.has_permission('teachers.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy staff_documents_delete on public.staff_documents for delete to authenticated using (app_private.is_super_admin() or (app_private.has_permission('teachers.delete') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy teacher_classes_insert on public.teacher_classes for insert to authenticated with check (app_private.is_super_admin() or (app_private.has_permission('teachers.create') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy teacher_classes_update on public.teacher_classes for update to authenticated using (app_private.is_super_admin() or (app_private.has_permission('teachers.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid())))) with check (app_private.is_super_admin() or (app_private.has_permission('teachers.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy teacher_classes_delete on public.teacher_classes for delete to authenticated using (app_private.is_super_admin() or (app_private.has_permission('teachers.delete') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy teacher_subjects_insert on public.teacher_subjects for insert to authenticated with check (app_private.is_super_admin() or (app_private.has_permission('teachers.create') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy teacher_subjects_update on public.teacher_subjects for update to authenticated using (app_private.is_super_admin() or (app_private.has_permission('teachers.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid())))) with check (app_private.is_super_admin() or (app_private.has_permission('teachers.edit') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
create policy teacher_subjects_delete on public.teacher_subjects for delete to authenticated using (app_private.is_super_admin() or (app_private.has_permission('teachers.delete') and institution_id=(select institution_id from public.profiles where id=(select auth.uid()))));
