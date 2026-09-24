-- Ready-to-use Bab Ul Ilm academic defaults for the primary institution.
-- Idempotent: safe to run repeatedly.
DO $$
DECLARE
  v_institution uuid;
BEGIN
  SELECT id INTO v_institution
  FROM public.institutions
  WHERE slug='bab-ul-ilm'
  ORDER BY created_at
  LIMIT 1;

  IF v_institution IS NULL THEN
    RETURN;
  END IF;

  INSERT INTO public.academic_classes (institution_id,name,code,level_order,active)
  SELECT v_institution,v.name,v.code,v.ord,true
  FROM (VALUES
    ('Nazra','NAZRA',1),('Hifz','HIFZ',2),
    ('Dars-e-Nizami 1','DN1',3),('Dars-e-Nizami 2','DN2',4),
    ('Dars-e-Nizami 3','DN3',5),('Dars-e-Nizami 4','DN4',6),
    ('Dars-e-Nizami 5','DN5',7),('Dars-e-Nizami 6','DN6',8)
  ) v(name,code,ord)
  ON CONFLICT (institution_id,code) DO UPDATE
    SET name=excluded.name,level_order=excluded.level_order,active=true;

  INSERT INTO public.subjects (institution_id,name,code,subject_type,active)
  SELECT v_institution,v.name,v.code,v.typ,true
  FROM (VALUES
    ('Quran','QURAN','quran'),('Tajweed','TAJWEED','quran'),('Hifz','HIFZ','quran'),
    ('Arabic','ARABIC','arabic'),('Fiqh','FIQH','fiqh'),('Hadith','HADITH','hadith'),
    ('Aqeedah','AQEEDAH','dars-e-nizami'),('Seerah','SEERAH','dars-e-nizami'),
    ('Urdu','URDU','urdu'),('English','ENGLISH','english'),('Mathematics','MATH','general')
  ) v(name,code,typ)
  ON CONFLICT (institution_id,code) DO UPDATE
    SET name=excluded.name,subject_type=excluded.subject_type,active=true;

  INSERT INTO public.sections (institution_id,class_id,name,code,capacity,active)
  SELECT v_institution,c.id,'Section A','A',40,true
  FROM public.academic_classes c
  WHERE c.institution_id=v_institution
  ON CONFLICT (class_id,code) DO UPDATE
    SET name=excluded.name,capacity=excluded.capacity,active=true;

  INSERT INTO public.class_subjects (institution_id,class_id,subject_id,weekly_periods,is_core)
  SELECT v_institution,c.id,s.id,2,true
  FROM public.academic_classes c
  CROSS JOIN public.subjects s
  WHERE c.institution_id=v_institution
    AND s.institution_id=v_institution
  ON CONFLICT (class_id,subject_id) DO NOTHING;
END $$;
