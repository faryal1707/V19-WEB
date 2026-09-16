BEGIN;

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('CLIENT','OPERATIONS','ADMIN');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE capacity_status AS ENUM ('AVAILABLE','AVAILABLE_SOON','HOLD','BOOKED','INACTIVE','EXPIRED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE equipment_type AS ENUM ('POWER_ONLY','DRY_VAN','FLATBED','STEP_DECK','CONESTOGA','REEFER','BOX_TRUCK','OTHER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE load_request_status AS ENUM ('RECEIVED','REVIEWING','ACCEPTED','DECLINED','CANCELLED');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE onboarding_status AS ENUM ('RECEIVED','REVIEWING','APPROVED','DECLINED','DUPLICATE');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE notification_channel AS ENUM ('EMAIL','SMS');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE notification_status AS ENUM ('QUEUED','PROCESSING','SENT','FAILED','DEAD');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  CREATE TYPE consent_type AS ENUM ('PRIVACY_ACKNOWLEDGEMENT','TERMS_ACCEPTANCE','TRANSACTIONAL_EMAIL','TRANSACTIONAL_SMS','MARKETING_EMAIL','MARKETING_SMS');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  legal_name text NOT NULL,
  dba_name text,
  mc_number text,
  dot_number text,
  archived_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (mc_number),
  UNIQUE (dot_number)
);

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email citext UNIQUE NOT NULL,
  password_hash text NOT NULL,
  display_name text NOT NULL,
  phone text,
  is_active boolean NOT NULL DEFAULT true,
  mfa_enabled boolean NOT NULL DEFAULT false,
  mfa_secret_encrypted text,
  mfa_pending_secret_encrypted text,
  mfa_pending_expires_at timestamptz,
  last_login_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS organization_users (
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role user_role NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (organization_id, user_id)
);

CREATE TABLE IF NOT EXISTS sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash bytea UNIQUE NOT NULL,
  csrf_hash bytea NOT NULL,
  mfa_verified boolean NOT NULL DEFAULT false,
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz,
  ip_hash bytea,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS sessions_user_active_idx ON sessions(user_id, expires_at) WHERE revoked_at IS NULL;

CREATE TABLE IF NOT EXISTS user_invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email citext NOT NULL,
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  role user_role NOT NULL,
  token_hash bytea UNIQUE NOT NULL,
  invited_by uuid REFERENCES users(id) ON DELETE SET NULL,
  expires_at timestamptz NOT NULL,
  accepted_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS user_invitations_pending_idx ON user_invitations(email, expires_at) WHERE accepted_at IS NULL;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash bytea UNIQUE NOT NULL,
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS trucks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  unit_number text NOT NULL,
  equipment_type equipment_type NOT NULL,
  display_equipment text NOT NULL,
  active boolean NOT NULL DEFAULT true,
  driver_mode text CHECK (driver_mode IN ('SOLO','TEAM','UNKNOWN')) DEFAULT 'UNKNOWN',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (organization_id, unit_number)
);
CREATE INDEX IF NOT EXISTS trucks_org_idx ON trucks(organization_id, active);

CREATE TABLE IF NOT EXISTS capacity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  truck_id uuid REFERENCES trucks(id) ON DELETE SET NULL,
  internal_unit_reference text,
  equipment_type equipment_type NOT NULL,
  display_equipment text NOT NULL,
  city text NOT NULL,
  state text NOT NULL CHECK (length(state) BETWEEN 2 AND 3),
  location geography(Point,4326) NOT NULL,
  available_at timestamptz NOT NULL,
  preferred_directions text[] NOT NULL DEFAULT '{}',
  status capacity_status NOT NULL DEFAULT 'AVAILABLE',
  public_notes text,
  internal_notes text,
  is_demo boolean NOT NULL DEFAULT false,
  archived_at timestamptz,
  updated_by uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS capacity_location_gix ON capacity USING gist(location);
CREATE INDEX IF NOT EXISTS capacity_status_date_idx ON capacity(status, available_at) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS capacity_equipment_idx ON capacity(equipment_type) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS capacity_updated_idx ON capacity(updated_at DESC);

CREATE TABLE IF NOT EXISTS load_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reference_number text UNIQUE NOT NULL,
  capacity_id uuid REFERENCES capacity(id) ON DELETE SET NULL,
  idempotency_key text UNIQUE NOT NULL,
  status load_request_status NOT NULL DEFAULT 'RECEIVED',
  origin_display text NOT NULL,
  destination_display text NOT NULL,
  pickup_at timestamptz NOT NULL,
  delivery_at timestamptz,
  equipment_type equipment_type NOT NULL,
  weight_lbs integer CHECK (weight_lbs IS NULL OR weight_lbs BETWEEN 1 AND 100000),
  commodity text,
  offered_rate_usd_cents integer CHECK (offered_rate_usd_cents IS NULL OR offered_rate_usd_cents >= 0),
  broker_company text NOT NULL,
  broker_contact_name text NOT NULL,
  broker_phone text NOT NULL,
  broker_email citext NOT NULL,
  notes text,
  transactional_contact_acknowledged boolean NOT NULL CHECK (transactional_contact_acknowledged),
  notification_state text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS load_requests_status_created_idx ON load_requests(status, created_at DESC);
CREATE INDEX IF NOT EXISTS load_requests_capacity_idx ON load_requests(capacity_id);

CREATE TABLE IF NOT EXISTS onboarding_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reference_number text UNIQUE NOT NULL,
  idempotency_key text UNIQUE NOT NULL,
  status onboarding_status NOT NULL DEFAULT 'RECEIVED',
  legal_name text NOT NULL,
  dba_name text,
  mc_number text NOT NULL,
  dot_number text,
  primary_contact text NOT NULL,
  email citext NOT NULL,
  phone text NOT NULL,
  truck_count integer NOT NULL CHECK (truck_count BETWEEN 1 AND 10000),
  equipment_types equipment_type[] NOT NULL,
  unit_details jsonb NOT NULL DEFAULT '[]'::jsonb,
  typical_location text,
  preferred_lanes text,
  avoid_regions text,
  home_time_preferences text,
  driver_mode text CHECK (driver_mode IN ('SOLO','TEAM','MIXED','UNKNOWN')) DEFAULT 'UNKNOWN',
  operational_notes text,
  selected_plan text NOT NULL CHECK (selected_plan IN ('CORE','PREMIUM','CUSTOM')),
  marketing_email_opt_in boolean NOT NULL DEFAULT false,
  marketing_sms_opt_in boolean NOT NULL DEFAULT false,
  transactional_sms_opt_in boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS onboarding_mc_idx ON onboarding_applications(mc_number, created_at DESC);
CREATE INDEX IF NOT EXISTS onboarding_status_idx ON onboarding_applications(status, created_at DESC);

CREATE TABLE IF NOT EXISTS consents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_type text NOT NULL CHECK (subject_type IN ('ONBOARDING_APPLICATION','LOAD_REQUEST','USER')),
  subject_id uuid NOT NULL,
  consent_type consent_type NOT NULL,
  granted boolean NOT NULL,
  disclosure_version text NOT NULL,
  disclosure_text_hash text NOT NULL,
  granted_at timestamptz NOT NULL DEFAULT now(),
  source text NOT NULL,
  ip_hash bytea,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS consents_subject_idx ON consents(subject_type, subject_id, consent_type);

CREATE TABLE IF NOT EXISTS loads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  truck_id uuid REFERENCES trucks(id) ON DELETE SET NULL,
  external_reference text,
  origin_display text NOT NULL,
  destination_display text NOT NULL,
  pickup_at timestamptz,
  delivered_at timestamptz,
  gross_rate_usd_cents integer NOT NULL CHECK (gross_rate_usd_cents >= 0),
  loaded_miles numeric(10,2) NOT NULL DEFAULT 0 CHECK (loaded_miles >= 0),
  deadhead_miles numeric(10,2) NOT NULL DEFAULT 0 CHECK (deadhead_miles >= 0),
  status text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS loads_org_delivered_idx ON loads(organization_id, delivered_at DESC);

CREATE TABLE IF NOT EXISTS load_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  load_id uuid NOT NULL REFERENCES loads(id) ON DELETE CASCADE,
  event_type text NOT NULL,
  event_at timestamptz NOT NULL DEFAULT now(),
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS load_events_load_idx ON load_events(load_id, event_at DESC);

CREATE TABLE IF NOT EXISTS documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  load_id uuid REFERENCES loads(id) ON DELETE CASCADE,
  document_type text NOT NULL,
  storage_key text NOT NULL,
  original_filename text NOT NULL,
  content_type text NOT NULL,
  size_bytes bigint NOT NULL CHECK (size_bytes >= 0),
  uploaded_by uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS documents_org_idx ON documents(organization_id, created_at DESC);
CREATE INDEX IF NOT EXISTS documents_load_idx ON documents(load_id, document_type);

CREATE TABLE IF NOT EXISTS reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  period_start date NOT NULL,
  period_end date NOT NULL,
  status text NOT NULL DEFAULT 'READY',
  snapshot jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (period_end >= period_start)
);
CREATE UNIQUE INDEX IF NOT EXISTS reports_org_period_uq ON reports(organization_id, period_start, period_end);

CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_key text NOT NULL,
  subject_type text NOT NULL,
  subject_id uuid,
  provider text NOT NULL,
  channel notification_channel NOT NULL,
  recipient text NOT NULL,
  template_key text NOT NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  status notification_status NOT NULL DEFAULT 'QUEUED',
  attempt_count integer NOT NULL DEFAULT 0,
  next_attempt_at timestamptz NOT NULL DEFAULT now(),
  last_attempt_at timestamptz,
  provider_message_id text,
  failure_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS notifications_queue_idx ON notifications(status, next_attempt_at) WHERE status IN ('QUEUED','FAILED');


CREATE TABLE IF NOT EXISTS web_vitals (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  metric_name text NOT NULL CHECK (metric_name IN ('LCP','INP','CLS')),
  metric_value numeric(14,4) NOT NULL CHECK (metric_value >= 0),
  rating text CHECK (rating IN ('good','needs-improvement','poor')),
  navigation_type text,
  page_path text NOT NULL CHECK (left(page_path,1) = '/'),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS web_vitals_metric_created_idx ON web_vitals(metric_name, created_at DESC);

CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  organization_id uuid REFERENCES organizations(id) ON DELETE SET NULL,
  action text NOT NULL,
  entity_type text NOT NULL,
  entity_id uuid,
  before_data jsonb,
  after_data jsonb,
  request_id text,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS audit_logs_entity_idx ON audit_logs(entity_type, entity_id, created_at DESC);
CREATE INDEX IF NOT EXISTS audit_logs_actor_idx ON audit_logs(actor_user_id, created_at DESC);

CREATE OR REPLACE FUNCTION touch_updated_at() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END $$;

DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY['organizations','users','trucks','capacity','load_requests','onboarding_applications','loads','notifications'] LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS %I_touch_updated_at ON %I', t, t);
    EXECUTE format('CREATE TRIGGER %I_touch_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION touch_updated_at()', t, t);
  END LOOP;
END $$;

COMMIT;
