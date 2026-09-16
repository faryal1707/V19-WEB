BEGIN;

-- DEMO DATA ONLY. Public production queries exclude is_demo=true unless explicitly enabled.
INSERT INTO organizations (id, legal_name, dba_name, mc_number, dot_number)
VALUES ('00000000-0000-4000-8000-000000000001', 'DEMO Carrier LLC', 'DEMO Carrier', 'DEMO-MC', 'DEMO-DOT')
ON CONFLICT DO NOTHING;

INSERT INTO trucks (id, organization_id, unit_number, equipment_type, display_equipment, driver_mode)
VALUES
('00000000-0000-4000-8000-000000000101','00000000-0000-4000-8000-000000000001','DEMO-214','DRY_VAN','53'' Dry Van','SOLO'),
('00000000-0000-4000-8000-000000000102','00000000-0000-4000-8000-000000000001','DEMO-308','FLATBED','48'' Flatbed','TEAM')
ON CONFLICT DO NOTHING;

INSERT INTO capacity (id, truck_id, internal_unit_reference, equipment_type, display_equipment, city, state, location, available_at, preferred_directions, status, public_notes, is_demo)
VALUES
('00000000-0000-4000-8000-000000000201','00000000-0000-4000-8000-000000000101','DEMO-214','DRY_VAN','53'' Dry Van','Dallas','TX',ST_SetSRID(ST_MakePoint(-96.7970,32.7767),4326)::geography,now()+interval '12 hours',ARRAY['SOUTHEAST'],'AVAILABLE','Example workflow only',true),
('00000000-0000-4000-8000-000000000202','00000000-0000-4000-8000-000000000102','DEMO-308','FLATBED','48'' Flatbed','Laredo','TX',ST_SetSRID(ST_MakePoint(-99.5075,27.5036),4326)::geography,now()+interval '1 day',ARRAY['NORTH','MIDWEST'],'AVAILABLE_SOON','Example workflow only',true)
ON CONFLICT DO NOTHING;

COMMIT;
