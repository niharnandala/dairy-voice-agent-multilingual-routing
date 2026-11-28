--Use farmer-agent-ro role connection for running this Tests. so that we can test the row level security policies work as expected.

-- test 1, pretend this call is for FM001, change the id for each farmer
begin;
select set_config('app.farmer_id', 'FM002', true);
select (select count(*) from cows)             as cows,
       (select count(*) from milk_records)     as milk,
       (select count(*) from breeding_records) as breeding,
       (select count(*) from vaccinations)     as vaccines,
       (select count(*) from health_records)   as health;
commit;

-- test 2, no farmer id set, so I should see nothing
begin;
select (select count(*) from cows)         as cows,
       (select count(*) from milk_records) as milk;
commit;

-- test 3, call is for FM001 but I try to read FM003's cows and milk
begin;
select set_config('app.farmer_id', 'FM001', true);
select count(*) from cows where farmer_id = 'FM003';
select count(*) from milk_records m join cows c on c.cow_id = m.cow_id where c.farmer_id = 'FM003';
commit;

-- test 4, the agent login must be able to read but not delete
select has_table_privilege('farm_agent_ro', 'cows', 'SELECT') as can_read,
       has_table_privilege('farm_agent_ro', 'cows', 'DELETE') as can_delete;

-- also try a real delete, wrapped so nothing is lost if it somehow works
begin;
delete from cows where farmer_id = 'FM001';
rollback;

-- test 5, I try to switch to another farmer from inside the query
begin;
select set_config('app.farmer_id', 'FM001', true);
select set_config('app.farmer_id', 'FM003', true);
select count(*) from cows;
commit;

/*This will return 100. That is not a pass.
 It proves the database lets the login change the setting, 
so the check in database.py must block set_config, set, reset and more than one statement.
 Later, when that check exists, the same query sent through it must be refused.*/