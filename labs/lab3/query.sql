-- 1. Скалярную функцию
create or replace function increment(i int) RETURNS int AS $$
        BEGIN
                RETURN i + 1;
        END;
$$ LANGUAGE plpgsql;

select increment(id) from nodes;

create or replace function node_with_biggest_ram() returns int as $$
	begin 
		return (select id from nodes where ram in (select max(ram) from nodes));
	end;
$$ language plpgsql;

select * from node_with_biggest_ram();

--  2. Подставляемая табличная функция
-- Без побочных эффектов ДЛЯ таблиц
-- это какой та баш

create or replace function ram_bigger(real) returns setof nodes as $$
	begin 
		return query (
			select * from nodes where ram > $1
		);
	end;
$$ language plpgsql;

select * from ram_bigger(100);

-- 3. Многооператорная функция
-- Ну тут как монада do в хаскеле

create or replace function get_nodes_quirky()
returns table(id int, ip varchar(100), device int, ram real)
as $$
	begin
		create temp table tmp(id int, ip varchar(100), device int, ram real);
		insert into tmp(id, ip, device, ram)
		select * from nodes where nodes.ram > 100;
		return query select * from tmp;
	end;
$$ language plpgsql;

select * from get_nodes_quirky();

-- 4. рекурсивная функция

drop function ram_recursive(r int);
create or replace function ram_recursive(r int)
returns setof nodes
as $$
	begin 
		return query (
			select * from nodes where abs(nodes.ram - r) < 1
		);
		if (r > 10) then
		return query (
			select * from ram_recursive(r - 10)
		);
	end if;
	end
$$ language plpgsql;

select * from ram_recursive(200);

-- Хранимые процедуры
-- 5. Хранимая процедура без параметров или с параметром


create or replace function update_something(device int, new_device int) returns void
as $$
	begin 
		update nodes
		set device_count = new_device
		where device_count = device;
	end;	
$$ language plpgsql;


select * from update_something(1, 2);

select * from nodes where device_count = 1;
select * from nodes where device_count = 2;

-- 6.

create table test_for_rec 
(
    id int,
    name text
);

insert into test_for_rec  (id, name) values (1, 'A');
insert into test_for_rec  (id, name) values (2, 'B');
insert into test_for_rec  (id, name) values (3, 'c');
insert into test_for_rec  (id, name) values (4, 'D');
insert into test_for_rec  (id, name) values (5, 'A');
insert into test_for_rec  (id, name) values (6, 'B');
insert into test_for_rec  (id, name) values (7, 'c');
insert into test_for_rec  (id, name) values (8, 'D');

create or replace function recurse_update_name (p_id int, p_new_name text) returns void
    as $$
    begin 
    update test_for_rec 
    set name = p_new_name
    where test_for_rec.id = p_id;

    if (p_id > 2) then perform * 
    from recurse_update_name(p_id - 2, p_new_name);
    end if;
    end;
    $$ language 'plpgsql';  

select * from recurse_update_name(8, 'NEW_NAME');
select * from test_for_rec;

-- 7. Хранимую процедуру с курсором

create or replace function update_device_cursor(device int, new_device int) returns void
as $$
begin 
	declare 
	rec record;
	cur cursor for select * from nodes where device_count = device;
	begin
		open cur;
		loop
			fetch cur into rec;
			exit when not found;
			update nodes 
			set device_count = new_device
			where nodes.id = rec.id;
		end loop;
		close cur;
	end;
end;
$$ language plpgsql;

select * from update_device_cursor(2,1);
select * from nodes where device_count = 1;
select * from nodes where device_count = 2;

-- 8. Хранимую процедуру доступа к метаданным


select table_name, count(*) as size
into my_tables
from information_schema.tables
where table_schema = 'public'
group by table_name;

select * from my_tables;

create or replace function table_size() returns void as 
$$
	declare 
		cur cursor for select table_name, size from
		(
			select table_name,
			pg_relation_size(cast(table_name as varchar)) as size
			from information_schema.tables
			where table_schema = 'public'
			order by  size desc
		) t;
		rec record;
	
	begin
		open cur;
		loop
			fetch cur into rec;
			exit when not found;
			raise notice 'table: %s size: %s', rec.table_name, rec.size;
			update 
				my_tables
				set size = rec.size
				where my_tables.table_name = rec.table_name;
		end loop;
		close cur;
	end;
$$ language plpgsql;

select * from table_size();
select * from my_tables;

-- 9. Trigger after

create or replace function  proc_after_trigger() returns trigger
as $$
	begin 
		RAISE NOTICE 'Запись в таблицу nodes: id(%), ip(%)', new.id, new.ip;
    	return new;
	end;
$$ language plpgsql

create trigger 
	check_node 
	after insert on nodes 
	for each row execute procedure proc_after_trigger();

insert into nodes(id, ip, device_count, ram) values(12345, '1.1.1.1', 3, 4.0);

-- 10. Instead of

create view test_view as
select *
from nodes;

create or replace function proc_instead_of_trigger() returns trigger as 
$$
	begin 
		raise notice 'Instead of!!!: Запись в таблицу nodes id %d', new.id;
		insert into nodes(id, ip, device_count, ram) values(new.id, new.ip, new.device_count, new.ram);
		return new;
	end;
$$ language plpgsql

create trigger instead_of_something
instead of insert on test_view
for each row 
execute procedure proc_instead_of_trigger();

insert into test_view(id, ip, device_count, ram) values(12346, '1.1.1.1', 3, 4.0);