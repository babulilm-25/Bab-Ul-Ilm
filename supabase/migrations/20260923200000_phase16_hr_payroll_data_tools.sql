-- Phase 16: HR/payroll and bulk-data permissions
create table if not exists public.staff_payroll (
 id uuid primary key default gen_random_uuid(),
 institution_id uuid not null references public.institutions(id) on delete cascade,
 staff_id uuid not null references public.staff(id) on delete cascade,
 pay_period date not null,
 basic numeric(14,2) not null default 0 check (basic >= 0),
 allowances numeric(14,2) not null default 0 check (allowances >= 0),
 deductions numeric(14,2) not null default 0 check (deductions >= 0),
 net_pay numeric(14,2) generated always as (basic + allowances - deductions) stored,
 status text not null default 'draft' check (status in ('draft','approved','paid','void')),
 payment_method text,
 reference_no text,
 paid_on date,
 notes text,
 created_by uuid,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(institution_id, staff_id, pay_period)
);
create index if not exists staff_payroll_institution_period_idx on public.staff_payroll(institution_id,pay_period);
create index if not exists staff_payroll_staff_period_idx on public.staff_payroll(staff_id,pay_period);
alter table public.staff_payroll enable row level security;
drop policy if exists staff_payroll_select on public.staff_payroll;
drop policy if exists staff_payroll_insert on public.staff_payroll;
drop policy if exists staff_payroll_update on public.staff_payroll;
drop policy if exists staff_payroll_delete on public.staff_payroll;
create policy staff_payroll_select on public.staff_payroll for select to authenticated using (app_private.institution_permission(institution_id,'hr.view'));
create policy staff_payroll_insert on public.staff_payroll for insert to authenticated with check (app_private.institution_permission(institution_id,'hr.create'));
create policy staff_payroll_update on public.staff_payroll for update to authenticated using (app_private.institution_permission(institution_id,'hr.edit')) with check (app_private.institution_permission(institution_id,'hr.edit'));
create policy staff_payroll_delete on public.staff_payroll for delete to authenticated using (app_private.institution_permission(institution_id,'hr.delete'));
insert into public.permissions(key,description,module) values
 ('hr.view','View HR and payroll','hr'),
 ('hr.create','Create payroll records','hr'),
 ('hr.edit','Edit payroll records','hr'),
 ('hr.delete','Delete payroll records','hr'),
 ('data.import','Import student CSV/Excel data','data')
on conflict (key) do nothing;
insert into public.role_permissions(role_id,permission_id)
select r.id,p.id from public.roles r cross join public.permissions p
where r.slug='admin' and p.key in ('hr.view','hr.create','hr.edit','hr.delete','data.import')
on conflict do nothing;