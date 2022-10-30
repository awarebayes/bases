select * from nodes;

-- Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres).

select row_to_json(n) from nodes n;


-- 2. Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

copy (select row_to_json(n) from  nodes n) to '/res/nodes.json';

create table if not exists nodes_import(doc json);

copy nodes_import from '/res/nodes.json';

select * from nodes_import;

-- 3. Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE.

create table if not exists nodes_json
(
	data json
);

insert into nodes_json 
select * from json_object('{id, ip, device_count,ram}', '{1, "2.3.4.5", 4, 123}');

select * from nodes_json;

CREATE TABLE IF NOT EXISTS json_table
(
	id serial PRIMARY KEY,
	name varchar(40) NOT NULL,
	DATA json
);

insert into json_table(name, data) values 
    ('Aboba', '{"age": 22, "occupation": "miller"}'::json),
    ('Biba', '{"age": 30, "occupation": "milker"}'::json),
    ('Biliboba', '{"age": 19, "occupation": "driller"}'::json);

select * from json_table;

--4. Выполнить следующие действия:
--4.1. Извлечь XML/JSON фрагмент из XML/JSON документа

create table if not exists nodes_ip_ram
(
	ip varchar(16),
	ram real
)

select * from nodes_import, json_populate_record(null::nodes_ip_ram, doc);

select doc->'ip' ip from nodes_import;

select doc->'ram' ram from nodes_import;



--4.2. Извлечь значения конкретных узлов или атрибутов XML/JSON
--документа

CREATE TABLE hobos 
(
    data jsonb
);
INSERT INTO hobos (data) VALUES 
('{"name": "Evgeniy", "age": 30, "home": {"type": "container", "place": "seashore"}}'), 
('{"name": "Evstasiy", "age": 45, "home": {"type": "hideout", "place": "forest"}}'),
('{"name": "Evdokim", "age": 69, "home": {"type": "shelter", "place": "city"}}');

SELECT data->'home'->'type' home_type FROM hobos;

-- !!!4.3. Выполнить проверку существования узла или атрибута
-- jsonb

CREATE TABLE hobos_id
(
	id serial primary key, 
    data jsonb
);

INSERT INTO hobos_id (id, data) VALUES 
(1, '{"name": "Evgeniy", "age": 30, "home": {"type": "container", "place": "seashore"}}'), 
(2, '{"name": "Evstasiy", "age": 45, "home": {"type": "hideout", "place": "forest"}}'),
(3, '{"name": "Evdokim", "home": {"type": "shelter", "place": "city"}}');;


CREATE OR REPLACE FUNCTION get_json_table(u_id int)
RETURNS VARCHAR AS '
    SELECT CASE
               WHEN count.cnt > 0
                   THEN ''true''
               ELSE ''false''
               END AS comment
    FROM (
             SELECT COUNT(data -> ''age'') cnt
             FROM hobos_id
             WHERE id < u_id
         ) AS count;
' LANGUAGE sql;


select * from get_json_table(2);


CREATE OR REPLACE FUNCTION key_exists(json_check jsonb, key text)
RETURNS BOOLEAN 
AS $$
BEGIN
    RETURN (json_check->key is not NULL);
END;
$$ LANGUAGE PLPGSQL;

SELECT key_exists('{"name": "Evdokiy", "age": 20}', 'age');


--4.4. Изменить XML/JSON документ
UPDATE hobos 
SET data = data || '{"age": 40}'::jsonb
WHERE (data->'age')::INT > 40;

SELECT * FROM hobos;


--4.5. Разделить XML/JSON документ на несколько строк по узлам
CREATE TABLE hobos_list
(
    doc json
);

insert into hobos_list(doc) values 
('[{"name": "Evgeniy", "age": 30, "home": {"type": "container", "place": "seashore"}},
{"name": "Evstasiy", "age": 45, "home": {"type": "hideout", "place": "forest"}},
{"name": "Evdokim", "age": 69, "home": {"type": "shelter", "place": "city"}}]');

SELECT jsonb_array_elements(doc::jsonb) 
FROM hobos_list;

SELECT * FROM hobos_list;