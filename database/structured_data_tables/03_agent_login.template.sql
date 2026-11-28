-- this file is a template, the real password never goes in here
-- before running it, I replaced <YOUR_PASSWORD> with my strong password on my own computer
-- and I never save or commit the filled version

-- the agent's login, it can only read
create role farm_agent_ro login password '<YOUR_PASSWORD>';

-- allow it to read all the tables, nothing else
grant select on all tables in schema public to farm_agent_ro;