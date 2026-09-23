-- Phase 14: Portal notification automation
alter table public.notifications add column if not exists metadata jsonb not null default '{}'::jsonb;
create index if not exists notifications_type_created_idx on public.notifications(notification_type, created_at desc);

create or replace function app_private.notify_student_portal(p_student_id uuid,p_title text,p_message text,p_type text)
returns void language plpgsql security definer set search_path=public,app_private as $$
begin
  insert into public.notifications(institution_id,user_id,title,message,notification_type,metadata)
  select pp.institution_id,pp.user_id,p_title,p_message,p_type,jsonb_build_object('student_id',p_student_id)
  from public.portal_profiles pp where pp.student_id=p_student_id and pp.active=true;
end; $$;
revoke execute on function app_private.notify_student_portal(uuid,text,text,text) from public,anon,authenticated;

create or replace function app_private.attendance_notification_trigger()
returns trigger language plpgsql security definer set search_path=public,app_private as $$
declare sname text;
begin
  if new.status in ('absent','late') then
    select concat_ws(' ',first_name,last_name) into sname from public.students where id=new.student_id;
    perform app_private.notify_student_portal(new.student_id,case when new.status='absent' then 'Attendance: Absent' else 'Attendance: Late' end,coalesce(sname,'Student')||' was marked '||new.status||' on attendance.','attendance');
  end if;
  return new;
end; $$;
drop trigger if exists attendance_portal_notification_trigger on public.attendance_records;
create trigger attendance_portal_notification_trigger after insert or update of status on public.attendance_records for each row execute function app_private.attendance_notification_trigger();
revoke execute on function app_private.attendance_notification_trigger() from public,anon,authenticated;

create or replace function app_private.fee_notification_trigger()
returns trigger language plpgsql security definer set search_path=public,app_private as $$
declare sname text;
begin
  if new.status in ('due','partial') and (tg_op='INSERT' or old.status is distinct from new.status or old.due_date is distinct from new.due_date) then
    select concat_ws(' ',first_name,last_name) into sname from public.students where id=new.student_id;
    perform app_private.notify_student_portal(new.student_id,'Fee status: '||new.status,coalesce(sname,'Student')||' fee of ₹'||trim(to_char(new.amount,'FM999999990.00'))||' is '||new.status||case when new.due_date is not null then ' (due '||new.due_date::text||').' else '.' end,'fees');
  end if;
  return new;
end; $$;
drop trigger if exists fee_assignment_portal_notification_trigger on public.student_fee_assignments;
create trigger fee_assignment_portal_notification_trigger after insert or update of status,due_date,amount on public.student_fee_assignments for each row execute function app_private.fee_notification_trigger();
revoke execute on function app_private.fee_notification_trigger() from public,anon,authenticated;

create or replace function app_private.result_notification_trigger()
returns trigger language plpgsql security definer set search_path=public,app_private as $$
declare subj text;
begin
  select cs.name into subj from public.exam_subjects es join public.class_subjects cs on cs.id=es.class_subject_id where es.id=new.exam_subject_id;
  perform app_private.notify_student_portal(new.student_id,'Result updated',coalesce(subj,'Exam subject')||': '||coalesce(new.marks::text,'0')||' marks'||case when new.grade is not null then ', grade '||new.grade else '' end||'.','results');
  return new;
end; $$;
drop trigger if exists exam_result_portal_notification_trigger on public.exam_results;
create trigger exam_result_portal_notification_trigger after insert or update of marks,grade,remarks on public.exam_results for each row execute function app_private.result_notification_trigger();
revoke execute on function app_private.result_notification_trigger() from public,anon,authenticated;
