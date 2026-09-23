-- Phase 19: production hardening
create index if not exists announcements_created_by_idx on public.announcements(created_by);
create index if not exists attendance_records_institution_fk_idx on public.attendance_records(institution_id);
create index if not exists attendance_sessions_section_fk_idx on public.attendance_sessions(section_id);
create index if not exists attendance_sessions_subject_fk_idx on public.attendance_sessions(subject_id);
create index if not exists attendance_sessions_teacher_fk_idx on public.attendance_sessions(teacher_id);
create index if not exists generated_documents_created_by_fk_idx on public.generated_documents(created_by);
create index if not exists generated_documents_template_fk_idx on public.generated_documents(template_id);
create index if not exists inventory_transactions_created_by_fk_idx on public.inventory_transactions(created_by);
create index if not exists library_issues_institution_fk_idx on public.library_issues(institution_id);
create index if not exists portal_profiles_institution_fk_idx on public.portal_profiles(institution_id);
create index if not exists student_certificates_issued_by_fk_idx on public.student_certificates(issued_by);
create index if not exists teacher_classes_section_fk_idx on public.teacher_classes(section_id);
create index if not exists timetable_entries_section_fk_idx on public.timetable_entries(section_id);
create index if not exists timetable_entries_subject_fk_idx on public.timetable_entries(subject_id);
