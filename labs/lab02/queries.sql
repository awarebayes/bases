-- 1. select with comparison
select id from volumes v 
where  v.task_id = 7;
-- 2. select with BETWEEN
select * from tasks t 
where t.time_created between  '2022-10-01 08:00' and '2022-10-02 09:00' 
order by time_created;
-- 3. SELECT with LIKE
select * from tasks t 
where t.name like 'a%';
-- 4. SELECT with IN
select * from volumes v  
where v.task_id in 
(
	select id from tasks t 
	where t."name" like 'a%'
);
-- 5. WHERE EXISTS
-- ноды на которых нет никаких тасков
select * from nodes 
where not exists (
	select 1 from tasks 
	where tasks.node_id = nodes.id
);
-- 6. SELECT with predicate comparison
select * from tasks t  where  t.id > all (select image_size from images i where i.image_name like 'a%');
-- 7. SELECT with aggregate functions in columns
select AVG(image_size), runtime from images group by runtime;
-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов
select runtime, image_size, 
	(select AVG(image_size) from images i where i.runtime = j.runtime) as avg_image_size,
	(select MIN(image_size) from images i where i.runtime = j.runtime) as min_image_size,
	image_name 
from images j;
-- 9. Инструкция SELECT, использующая простое выражение CASE
-- select * from images join tasks on images.id = tasks.image_id;
select *,
	  case extract(isodow from time_created)
	  	when 1 then 'Monday'
	  	when 2 then 'Tuesday'
	  	when 3 then 'Wotansday'
	  	when 4 then 'Thursday'
	  	when 5 then 'Friday'
	  	when 6 then 'Saturday'
	  	when 7 then 'Sunday'
	  	else 'Some other day'
	  end as dow
from tasks;
-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
select *,
	  case
	  	when extract(isodow from time_created) <= 5 then 'Work day'
		else 'Day off'
	  end as day_type
from tasks;
-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT
select id, image_size into temp temp_table from images;
-- 12. Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM
select avg_size_of_runtime as Criteria, image_name from images i join 
	(select avg(image_size) as avg_size_of_runtime, runtime  from images group by runtime) as rt on rt.runtime = i.runtime
union 
select avg_size_cuda as Criteria, image_name from images i join 
	(select avg(image_size) as avg_size_cuda, need_device  from images group by need_device) as dev on dev.need_device = i.need_device;
-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3. 
select ip from nodes n where n.id in 
(
	select node_id from tasks t where t.id in 
	(
		select id from (
			select * from task_statuses ts where ts.status like 'a%'
		) t3 where status like 'ab%'
	)
);
-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING. 
-- Для каждого таска имя которого начинается на a получить кол-во видеокарт на ноде
select t."name", n.device_count, avg(n.device_count), min(n.device_count) 
	from tasks t join nodes n on t.node_id = n.id where t."name" like 'a%'
	group by t.id, n.device_count;
-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING. 
-- avg первая часть ip ноды у которой больше среднего видеокарт

-- REDO с аггрегатной функией

--select s.device_count, avg(first_ip) from (
--	select *, split_part(ip::text, '.', 1)::int as first_ip from nodes
--	) as s
--	group by s.device_count
--	having s.device_count > (select avg(device_count) as MDevice from nodes);

select device_count, avg(ram) from nodes
	group by device_count
	having avg(ram) > 100;

-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
insert into nodes(id, ip, device_count) values(1001, '203.23.12.3', 3);
-- 17.  Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса
--
insert into nodes(id, ip, device_count)
	values((select max(id) + 1 from nodes), '205.23.12.3', 3);
-- 18. Простая инструкция UPDATE. 
update nodes
set ip = '123.456.123.123'
where id = '1';
-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET
update nodes
set device_count = (
	select avg(device_count) from nodes
)
where id = '1';
-- 20. Простая инструкция DELETE. 
delete from nodes where ip is null;
-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
-- Удалим все ноды на которых запускались таски с именем like ab%
delete from nodes where id in (select id from nodes where nodes.id  in (select t.node_id from tasks t where t.name like 'ab%'));
-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение
with CTE (dev_cnt, num_of_tasks) as (
	select device_count, count(*) as total
	from nodes group by device_count
) 
select dev_cnt, num_of_tasks from CTE;

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение
create table employees (
	employee_id serial primary key,
	full_name varchar not null,
	manager_id INT
);

INSERT INTO employees (
	employee_id,
	full_name,
	manager_id
)
VALUES
	(1, 'Michael North', NULL),
	(2, 'Megan Berry', 1),
	(3, 'Sarah Berry', 1),
	(4, 'Zoe Black', 1),
	(5, 'Tim James', 1),
	(6, 'Bella Tucker', 2),
	(7, 'Ryan Metcalfe', 2),
	(8, 'Max Mills', 2),
	(9, 'Benjamin Glover', 2),
	(10, 'Carolyn Henderson', 3),
	(11, 'Nicola Kelly', 3),
	(12, 'Alexandra Climo', 3),
	(13, 'Dominic King', 3),
	(14, 'Leonard Gray', 4),
	(15, 'Eric Rampling', 4),
	(16, 'Piers Paige', 7),
	(17, 'Ryan Henderson', 7),
	(18, 'Frank Tucker', 8),
	(19, 'Nathan Ferguson', 8),
	(20, 'Kevin Rampling', 8);

with recursive subordinates as (
	select employee_id, manager_id, full_name
	from employees
	where employee_id = 2
	union
		select e.employee_id, e.manager_id, e.full_name
		from employees e
		inner join subordinates s on s.employee_id = e.manager_id
) select * from subordinates;

-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
select *, AVG(ram) over (partition by device_count) as AvgRam,
		  MIN(ram) over (partition by device_count) as MinRam,
		  MAX(ram) over (partition by device_count) as MaxRam
		from nodes;
	
-- 25. Оконные фнкции для устранения дублей

select * from tasks t join nodes on nodes.id = t.id;

-- дубликаты
with busy_nodes(node_id) as (select node_id from tasks where node_id in (
	select node_id from (select node_id, count(node_id) from tasks group by node_id) as t where count > 1
) order by node_id)
select * from (nodes n join busy_nodes bn on n.id  = bn.node_id);

-- отфильтрованные дубликаты
with counted_dublicates as (
	with dublicates as (
		with busy_nodes(node_id) as (select node_id from tasks where node_id in (
			select node_id from (select node_id, count(node_id) from tasks group by node_id) as t where count > 1
		) order by node_id)
		select * from (nodes n join busy_nodes bn on n.id  = bn.node_id)
	)
	select *, row_number() over (partition by id) as r_id from dublicates
) select * from counted_dublicates where r_id = 1;