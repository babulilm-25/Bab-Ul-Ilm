-- Phase 9: database audit coverage for high-impact records
create or replace function public.audit_row_change()
returns trigger
language plpgsql
security definer
set search_path = public, app_private
as $$
declare
  v_row jsonb;
  v_id text;
  v_institution uuid;
  v_branch uuid;
begin
  v_row := case when TG_OP='DELETE' then to_jsonb(OLD) else to_jsonb(NEW) end;
  v_id := coalesce(v_row->>'id', v_row->>'student_id', v_row->>'user_id');
  begin v_institution := (v_row->>'institution_id')::uuid; exception when others then v_institution := null; end;
  begin v_branch := (v_row->>'branch_id')::uuid; exception when others then v_branch := null; end;
  insert into public.audit_logs(institution_id,actor_user_id,action,entity_type,entity_id,branch_id,metadata)
  values(v_institution,auth.uid(),lower(TG_OP)||'_row',TG_TABLE_NAME,v_id,v_branch,
    jsonb_build_object('source','database_trigger','new',case when TG_OP='DELETE' then null else v_row end,'old',case when TG_OP='INSERT' then null else to_jsonb(OLD) end));
  return case when TG_OP='DELETE' then OLD else NEW end;
end $$;

revoke all on function public.audit_row_change() from public,anon,authenticated;

do $$
declare t text;
begin
 foreach t in array array['students','admissions','student_enrollments','student_promotions','attendance_records','exam_results','student_fee_assignments','fee_payments','hostel_allocations','library_issues','inventory_transactions'] loop
   execute format('drop trigger if exists audit_row_change on public.%I',t);
   execute format('create trigger audit_row_change after insert or update or delete on public.%I for each row execute function public.audit_row_change()',t);
 end loop;
end $$;
