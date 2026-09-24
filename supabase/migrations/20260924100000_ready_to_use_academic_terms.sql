-- Ready-to-use academic term defaults for the seeded Bab Ul Ilm academic year.
-- Idempotent: only inserts terms that do not already exist for the year.
insert into public.academic_terms (institution_id, academic_year_id, name, code, starts_on, ends_on, active)
select i.id, y.id, v.name, v.code, v.starts_on, v.ends_on, v.active
from public.institutions i
join public.academic_years y on y.institution_id = i.id and y.name = '2026-27'
cross join (values
  ('Term 1','T1','2026-03-29'::date,'2026-06-30'::date,false),
  ('Term 2','T2','2026-07-01'::date,'2026-10-31'::date,true),
  ('Term 3','T3','2026-11-01'::date,'2027-02-08'::date,false)
) v(name, code, starts_on, ends_on, active)
where i.slug = 'bab-ul-ilm'
  and not exists (
    select 1 from public.academic_terms t
    where t.institution_id = i.id
      and t.academic_year_id = y.id
      and t.code = v.code
  );
