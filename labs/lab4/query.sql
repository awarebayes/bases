select * from pg_language;

select name, default_version, installed_version from pg_catalog.pg_available_extensions ;

-- 1. скалярная функция
create or replace function get_ip(id INT)
returns varchar as $$
res = plpy.execute(
f"""
select ip
from nodes
where id = {id};
""", 1)
if res:
	return res[0]['ip']
$$ language plpython3u;

select * from nodes;
select * from get_ip(4);
select * from nodes where ip = get_ip(4);


-- 2. агрегатная функция

create or replace function count_device(__ int, lower_id int, upper_id int)
returns int as $$
	dc = plpy.execute(f"""
		select device_count from nodes where id > {lower_id} and id < {upper_id};
	"""
	)
	print(dc[0])
	dc = map(lambda x: x[list(x.keys())[0]], dc)
	return sum(dc)
$$ language plpython3u;



create or replace aggregate CountDevice(lower_id int, upper_id int)
(
	sfunc = count_device,
	stype = int
);


select CountDevice(1, 10) from nodes;

-- 3. Табличная функция

drop function get_nodes();

create or replace function get_nodes()
returns table(
    id INT,
    ip VARCHAR(32),
    device_count INT, -- CHECK(device_count >= 0)
    ram REAL
) as $$
	results = plpy.execute(f"""
		select * from nodes;
	"""
	)
	return results
$$ language plpython3u;

select * from get_nodes();

-- 4. Хранимая процедура 

create or replace function change_device(old_device int, new_device int)
returns void as $$
	plan = plpy.prepare("update nodes set device_count = $1 where device_count = $2", ["INT", "INT"])
	plpy.execute(plan, [new_device, old_device])
$$ language plpython3u;

select * from change_device(1, 2);
select * from nodes;


-- 5. Триггер

create view nodesv as 
select * from nodes;

create or replace function delete_node()
returns trigger as $$
	del_id = TD["old"]["id"]
	plpy.notice(f"Deleted: {del_id}")
	return TD["new"]
$$ language plpython3u;

drop trigger delete_node_trigger on nodesv;

create trigger delete_node_trigger
instead of delete on nodesv 
for each row execute procedure delete_node();


delete from nodes where id = 5;

select * from nodes;

-- 6. Определяемый пользователем тип данных

create type mytype as 
(
	id int,
	device_count int
)

create or replace function get_iddevcnt()
returns mytype as $$
	run = plpy.execute("""
		select * from nodes;
	""")
	if (run.nrows()):
		return run[0]['id'], run[0]['device_count']
$$ language plpython3u;

select * from get_iddevcnt();


