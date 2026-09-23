-- Phase 3: admissions workflow, lifecycle history, promotion safety, hostel/mess/library/inventory foundations
create table if not exists public.student_lifecycle_events (
 id uuid primary key default gen_random_uuid(),
 institution_id uuid not null references public.institutions(id) on delete cascade,
 student_id uuid not null references public.students(id) on delete cascade,
 event_type text not null,
 from_value jsonb not null default '{}'::jsonb,
 to_value jsonb not null default '{}'::jsonb,
 remarks text,
 actor_user_id uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now()
);
create index if not exists student_lifecycle_student_created_idx on public.student_lifecycle_events(student_id,created_at desc);
alter table public.student_lifecycle_events enable row level security;
create policy lifecycle_select on public.student_lifecycle_events for select to authenticated using(app_private.same_institution(institution_id) and (app_private.is_super_admin() or app_private.has_permission('students.view')));
create policy lifecycle_insert on public.student_lifecycle_events for insert to authenticated with check(app_private.same_institution(institution_id) and (app_private.is_super_admin() or app_private.has_permission('students.edit')));
grant select,insert on public.student_lifecycle_events to authenticated;
create or replace function public.change_student_status(target_student uuid,target_status text,target_remarks text default null) returns jsonb language plpgsql security invoker set search_path=public as $$
declare old_status text; inst uuid;
begin
 if target_status not in ('active','inactive','suspended','withdrawn','completed','alumni') then raise exception 'Invalid student status'; end if;
 select institution_id,status into inst,old_status from public.students where id=target_student for update;
 if inst is null then raise exception 'Student not found'; end if;
 if not(app_private.is_super_admin() or app_private.has_permission('students.edit')) then raise exception 'Not authorized'; end if;
 if not app_private.same_institution(inst) then raise exception 'Institution mismatch'; end if;
 update public.students set status=target_status,updated_at=now() where id=target_student;
 insert into public.student_lifecycle_events(institution_id,student_id,event_type,from_value,to_value,remarks,actor_user_id) values(inst,target_student,'status_change',jsonb_build_object('status',old_status),jsonb_build_object('status',target_status),target_remarks,auth.uid());
 insert into public.audit_logs(institution_id,actor_user_id,action,entity_type,entity_id,metadata) values(inst,auth.uid(),'student.status_changed','student',target_student::text,jsonb_build_object('from',old_status,'to',target_status,'remarks',target_remarks));
 return jsonb_build_object('student_id',target_student,'from',old_status,'to',target_status);
end $$;
revoke all on function public.change_student_status(uuid,text,text) from public,anon;
grant execute on function public.change_student_status(uuid,text,text) to authenticated;

create table if not exists public.hostel_buildings (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade,
 name text not null, code text not null, floors int not null default 1 check(floors>0), active boolean not null default true,
 unique(institution_id,code)
);
create table if not exists public.hostel_rooms (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade,
 building_id uuid not null references public.hostel_buildings(id) on delete cascade, room_no text not null,
 capacity int not null check(capacity>0), active boolean not null default true,
 unique(building_id,room_no)
);
create table if not exists public.hostel_beds (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade,
 room_id uuid not null references public.hostel_rooms(id) on delete cascade, bed_no text not null,
 status text not null default 'available' check(status in ('available','occupied','maintenance')),
 unique(room_id,bed_no)
);
create table if not exists public.hostel_allocations (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade,
 student_id uuid not null references public.students(id) on delete cascade, bed_id uuid not null references public.hostel_beds(id) on delete restrict,
 allocated_on date not null default current_date, released_on date, status text not null default 'active' check(status in ('active','released','transferred')),
 unique(student_id,status)
);
create table if not exists public.hostel_attendance (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade,
 student_id uuid not null references public.students(id) on delete cascade, attendance_date date not null, status text not null check(status in ('present','absent','leave')),
 unique(student_id,attendance_date)
);
create table if not exists public.mess_meal_plans (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade,
 name text not null, description text, active boolean not null default true
);
create table if not exists public.mess_menus (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade,
 meal_date date not null, meal_type text not null check(meal_type in ('breakfast','lunch','dinner','snack')), menu text not null,
 unique(institution_id,meal_date,meal_type)
);
create table if not exists public.mess_attendance (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade,
 student_id uuid not null references public.students(id) on delete cascade, meal_date date not null, meal_type text not null,
 status text not null default 'present' check(status in ('present','absent','leave')),
 unique(student_id,meal_date,meal_type)
);
create table if not exists public.inventory_categories (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade, name text not null, unique(institution_id,name)
);
create table if not exists public.inventory_suppliers (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade, name text not null, phone text, email text, unique(institution_id,name)
);
create table if not exists public.library_book_copies (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete cascade, book_id uuid not null references public.library_books(id) on delete cascade,
 barcode text not null, status text not null default 'available' check(status in ('available','issued','lost','damaged')),
 unique(institution_id,barcode)
);
create index if not exists hostel_rooms_building_idx on public.hostel_rooms(building_id);
create index if not exists hostel_beds_room_idx on public.hostel_beds(room_id);
create index if not exists hostel_alloc_student_idx on public.hostel_allocations(student_id);
create index if not exists mess_attendance_date_idx on public.mess_attendance(institution_id,meal_date);
create index if not exists library_copies_book_idx on public.library_book_copies(book_id);
alter table public.hostel_buildings enable row level security; alter table public.hostel_rooms enable row level security; alter table public.hostel_beds enable row level security; alter table public.hostel_allocations enable row level security; alter table public.hostel_attendance enable row level security; alter table public.mess_meal_plans enable row level security; alter table public.mess_menus enable row level security; alter table public.mess_attendance enable row level security; alter table public.inventory_categories enable row level security; alter table public.inventory_suppliers enable row level security; alter table public.library_book_copies enable row level security;
create or replace function app_private.institution_permission(target_institution uuid, perm text) returns boolean language sql stable security definer set search_path=public,app_private as $$ select target_institution=(select institution_id from public.profiles where id=auth.uid()) and (app_private.is_super_admin() or app_private.has_permission(perm)); $$;
revoke all on function app_private.institution_permission(uuid,text) from public,anon; grant execute on function app_private.institution_permission(uuid,text) to authenticated;
do $$ declare t text; begin foreach t in array array['hostel_buildings','hostel_rooms','hostel_beds','hostel_allocations','hostel_attendance','mess_meal_plans','mess_menus','mess_attendance','inventory_categories','inventory_suppliers','library_book_copies'] loop execute format('create policy %I_select on public.%I for select to authenticated using(app_private.institution_permission(institution_id,''students.view''))',t,t); execute format('create policy %I_write on public.%I for all to authenticated using(app_private.institution_permission(institution_id,''students.edit'')) with check(app_private.institution_permission(institution_id,''students.edit''))',t,t); execute format('grant select,insert,update,delete on public.%I to authenticated',t); end loop; end $$;
