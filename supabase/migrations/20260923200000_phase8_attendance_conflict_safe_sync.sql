-- Phase 8: conflict-safe offline attendance synchronization
create or replace function public.sync_attendance_batch(p_rows jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = public, app_private
as $$
declare
  r jsonb;
  v_user uuid := auth.uid();
  v_institution uuid;
  v_session uuid;
  v_student uuid;
  v_status text;
  v_remarks text;
  v_existing record;
  v_synced int := 0;
  v_same int := 0;
  v_conflicts jsonb := '[]'::jsonb;
  v_errors jsonb := '[]'::jsonb;
begin
  if v_user is null then raise exception 'Authentication required'; end if;
  select institution_id into v_institution from public.profiles where id=v_user;
  if v_institution is null then raise exception 'Institution not configured'; end if;
  if not app_private.has_permission('attendance.create') and not app_private.has_permission('attendance.edit') then
    raise exception 'Attendance permission required';
  end if;
  if jsonb_typeof(p_rows) <> 'array' then raise exception 'Rows must be a JSON array'; end if;

  for r in select value from jsonb_array_elements(p_rows) loop
    begin
      v_session := (r->>'session_id')::uuid;
      v_student := (r->>'student_id')::uuid;
      v_status := lower(coalesce(r->>'status','present'));
      v_remarks := nullif(r->>'remarks','');
      if v_status not in ('present','absent','leave','late','half_day') then
        v_errors := v_errors || jsonb_build_array(jsonb_build_object('session_id',v_session,'student_id',v_student,'error','Invalid attendance status'));
        continue;
      end if;
      if not exists(select 1 from public.attendance_sessions s where s.id=v_session and s.institution_id=v_institution) then
        v_errors := v_errors || jsonb_build_array(jsonb_build_object('session_id',v_session,'student_id',v_student,'error','Session not found in institution'));
        continue;
      end if;
      if not exists(select 1 from public.students s where s.id=v_student and s.institution_id=v_institution) then
        v_errors := v_errors || jsonb_build_array(jsonb_build_object('session_id',v_session,'student_id',v_student,'error','Student not found in institution'));
        continue;
      end if;
      select * into v_existing from public.attendance_records ar where ar.session_id=v_session and ar.student_id=v_student for update;
      if found then
        if v_existing.status=v_status and v_existing.remarks is not distinct from v_remarks then
          v_same := v_same + 1;
        else
          v_conflicts := v_conflicts || jsonb_build_array(jsonb_build_object('session_id',v_session,'student_id',v_student,'existing_status',v_existing.status,'existing_remarks',v_existing.remarks,'incoming_status',v_status,'incoming_remarks',v_remarks));
        end if;
      else
        insert into public.attendance_records(institution_id,session_id,student_id,status,remarks)
        values(v_institution,v_session,v_student,v_status,v_remarks);
        v_synced := v_synced + 1;
      end if;
    exception when others then
      v_errors := v_errors || jsonb_build_array(jsonb_build_object('session_id',r->>'session_id','student_id',r->>'student_id','error',sqlerrm));
    end;
  end loop;
  return jsonb_build_object('synced',v_synced,'already_synced',v_same,'conflicts',v_conflicts,'errors',v_errors);
end $$;

revoke all on function public.sync_attendance_batch(jsonb) from public, anon;
grant execute on function public.sync_attendance_batch(jsonb) to authenticated;
