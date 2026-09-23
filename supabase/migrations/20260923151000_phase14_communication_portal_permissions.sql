-- Phase 14: communication and portal granular permissions
insert into public.permissions(key,description,module) values
('communication.view','View communication','communication'),
('communication.create','Create communication','communication'),
('communication.edit','Edit communication','communication'),
('portal.view','View portal links','portal'),
('portal.create','Create portal links','portal'),
('portal.edit','Edit portal links','portal')
on conflict (key) do nothing;
