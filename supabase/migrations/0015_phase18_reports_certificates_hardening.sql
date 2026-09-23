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
