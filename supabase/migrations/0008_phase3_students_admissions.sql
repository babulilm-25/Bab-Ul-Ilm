-- Phase 3: Students, guardians and admissions
create table if not exists public.students (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete restrict,
 admission_no text not null, roll_no text, first_name text not null, middle_name text, last_name text, preferred_name text,
 gender text check (gender in ('male','female','other')), date_of_birth date, phone text, email text,
 address jsonb not null default '{}'::jsonb, guardian_name text, guardian_phone text, guardian_relation text,
 photo_path text, status text not null default 'active' check (status in ('active','inactive','graduated','transferred','withdrawn','archived')),
 joined_on date, notes text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(institution_id, admission_no)
);
create table if not exists public.student_guardians (
 id uuid primary key default gen_random_uuid(), student_id uuid not null references public.students(id) on delete cascade,
 full_name text not null, relation text not null, phone text, email text, occupation text, is_primary boolean not null default false,
 created_at timestamptz not null default now(), unique(student_id, phone)
);
create table if not exists public.admissions (
 id uuid primary key default gen_random_uuid(), institution_id uuid not null references public.institutions(id) on delete restrict,
 student_id uuid references public.students(id) on delete set null, application_no text not null, applied_on date not null default current_date,
 status text not null default 'pending' check (status in ('pending','approved','rejected','waitlisted','cancelled','converted')),
 program text, class_name text, source text, remarks text, reviewed_by uuid references auth.users(id) on delete set null,
 reviewed_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 unique(institution_id, application_no)
);
create index if not exists students_institution_status_idx on public.students(institution_id,status);
create index if not exists students_institution_name_idx on public.students(institution_id,first_name,last_name);
create index if not exists student_guardians_student_idx on public.student_guardians(student_id);
create index if not exists admissions_institution_status_idx on public.admissions(institution_id,status);
create index if not exists admissions_student_idx on public.admissions(student_id);
alter table public.students enable row level security; alter table public.student_guardians enable row level security; alter table public.admissions enable row level security;
-- Policies are defined in the deployed database and must be kept in sync with this migration.
