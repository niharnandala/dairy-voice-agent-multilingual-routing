-- This is a structured data base connected for postgreSQL in Neon.

-- 1. farmers: who is calling
CREATE TABLE farmers (
    farmer_id           TEXT PRIMARY KEY,             -- FM001, like CU001 in banking
    name                TEXT NOT NULL,
    phone               TEXT UNIQUE NOT NULL,         -- caller ID can identify the farmer on a real call
    village             TEXT,
    district       TEXT NOT NULL,
    state               TEXT NOT NULL,
    preferred_language  TEXT NOT NULL CHECK (preferred_language IN ('te','hi','hinglish','en')),
    created_at          TIMESTAMPTZ DEFAULT now()
);

-- 2. cows: the herd (cows, buffaloes, heifers and calves, all female)
CREATE TABLE cows (
    cow_id              SERIAL PRIMARY KEY,
    farmer_id           TEXT NOT NULL REFERENCES farmers(farmer_id),
    tag_number          INT  NOT NULL,                -- "cow number 25", what the farmer actually says
    name                TEXT,                         -- farmers often call cows by name, like Lakshmi
    species             TEXT NOT NULL CHECK (species IN ('cattle','buffalo')),
    breed               TEXT NOT NULL,                -- Gir, Sahiwal, Murrah, Jersey crossbred, HF crossbred
    birth_date          DATE NOT NULL,
    lactation_number    INT  NOT NULL DEFAULT 0,      -- how many times she has calved (0 = heifer or calf)
    status              TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','sold','dead')),
    UNIQUE (farmer_id, tag_number)
);

-- 3. milk_records: one row per cow per milking
CREATE TABLE milk_records (
    id                  SERIAL PRIMARY KEY,
    cow_id              INT  NOT NULL REFERENCES cows(cow_id),
    record_date         DATE NOT NULL,
    session             TEXT NOT NULL CHECK (session IN ('morning','evening')),
    litres              NUMERIC(5,2) NOT NULL CHECK (litres >= 0),
    UNIQUE (cow_id, record_date, session)
);

-- 4. breeding_records: insemination, pregnancy, calving
CREATE TABLE breeding_records (
    id                     SERIAL PRIMARY KEY,
    cow_id                 INT  NOT NULL REFERENCES cows(cow_id),
    insemination_date      DATE NOT NULL,
    method                 TEXT CHECK (method IN ('AI','natural')),
    bull_breed             TEXT,
    pregnancy_confirmed    BOOLEAN DEFAULT false,
    confirmed_date         DATE,
    expected_calving_date  DATE,
    actual_calving_date    DATE,
    outcome                TEXT CHECK (outcome IN ('pending','calved','failed','aborted'))
);

-- 5. vaccinations: given and next due
--    Each cow keeps every dose given in the data window, plus her latest older dose
--    for each vaccine, so "is she overdue" can always be answered.
CREATE TABLE vaccinations (
    id                  SERIAL PRIMARY KEY,
    cow_id              INT  NOT NULL REFERENCES cows(cow_id),
    vaccine_name        TEXT NOT NULL,               -- FMD, HS+BQ, LSD, Brucellosis (S19), Theileriosis
    given_date          DATE NOT NULL,
    next_due_date       DATE                         -- NULL for once-in-a-lifetime vaccines
);

-- 6. health_records: medical history written by the vet or farmer
CREATE TABLE health_records (
    id                  SERIAL PRIMARY KEY,
    cow_id              INT  NOT NULL REFERENCES cows(cow_id),
    record_date         DATE NOT NULL,
    symptoms            TEXT,
    diagnosis           TEXT,                        -- only what a vet wrote, the agent never fills this
    treatment           TEXT,
    vet_name            TEXT,                        -- NULL when the farmer treated it himself
    resolved            BOOLEAN DEFAULT false
);

-- indexes for the fixed queries
CREATE INDEX ON milk_records (cow_id, record_date);
CREATE INDEX ON vaccinations (cow_id, vaccine_name, given_date);
CREATE INDEX ON vaccinations (next_due_date);
CREATE INDEX ON breeding_records (cow_id, outcome);
CREATE INDEX ON health_records (cow_id, record_date);

-- read-only user for the agent, so generated SQL can never change data..
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'farm_agent_ro') THEN
        CREATE ROLE farm_agent_ro LOGIN PASSWORD 'here i hided the password';
    END IF;
END $$;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO farm_agent_ro;
