-- farmers table, locking it so only the farmer thats calling  of this call is visible
alter table farmers enable row level security;
create policy only_this_farmer on farmers for select to farm_agent_ro
  using (farmer_id = current_setting('app.farmer_id', true));

-- cows table, same idea
alter table cows enable row level security;
create policy only_this_farmer on cows for select to farm_agent_ro
  using (farmer_id = current_setting('app.farmer_id', true));

-- these 4 tables have no farmer_id, so I check that the cow belongs to this farmer
alter table milk_records enable row level security;
create policy only_this_farmer on milk_records for select to farm_agent_ro
  using (cow_id in (select cow_id from cows where farmer_id = current_setting('app.farmer_id', true)));

alter table breeding_records enable row level security;
create policy only_this_farmer on breeding_records for select to farm_agent_ro
  using (cow_id in (select cow_id from cows where farmer_id = current_setting('app.farmer_id', true)));

alter table vaccinations enable row level security;
create policy only_this_farmer on vaccinations for select to farm_agent_ro
  using (cow_id in (select cow_id from cows where farmer_id = current_setting('app.farmer_id', true)));

alter table health_records enable row level security;
create policy only_this_farmer on health_records for select to farm_agent_ro
  using (cow_id in (select cow_id from cows where farmer_id = current_setting('app.farmer_id', true)));