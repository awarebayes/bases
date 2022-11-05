import streamlit as st
import psycopg2
import pandas as pd


con = psycopg2.connect(
    host="localhost", database="postgres", user="postgres", password="secret"
)
cur = con.cursor()
node_column_names = ["id", "ip", "device_count", "ram"]


def show_table(sql_query):
    st.code(sql_query, language="sql")
    cur.execute(sql_query)
    try:
        res = cur.fetchall()
    except:
        res = []
    df = pd.DataFrame(res)
    st.dataframe(df)

st.title("Lab 6")

if st.checkbox("1. Select"):
    show_table("SELECT * FROM nodes")

if st.checkbox("2. Select with join"):
    show_table("SELECT * from tasks join nodes on tasks.node_id = nodes.id")

if st.checkbox("3. CTE and window function"):
    show_table(
        """with cte as (select *, AVG(ram) over (partition by device_count) as AvgRam,
		      MIN(ram) over (partition by device_count) as MinRam,
		      MAX(ram) over (partition by device_count) as MaxRam
		from nodes)
    select * from cte;
    """
    )

if st.checkbox("4. Metadata query"):
    show_table("select * from pg_catalog.pg_tables")

if st.checkbox("5. Scalar function"):
    show_table(
        """
        create or replace function node_with_biggest_ram() returns int as $$
        begin 
                return (select id from nodes where ram in (select max(ram) from nodes));
            end;
        $$ language plpgsql;
        select * from node_with_biggest_ram();
        """
    )

if st.checkbox("6. Multi operator function"):
    show_table(
        """
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
        """
    )

if st.checkbox("7. Stored Procedure"):
    st.write("Going to create a stored procedure")
    cur.execute(
        """
        create or replace function update_something(device int, new_device int) returns void
        as $$
            begin 
                update nodes
                set device_count = new_device
                where device_count = device;
            end;	
        $$ language plpgsql;
        """
    )
    con.commit()

    st.write("Stored procedure created")
    if st.button("1->2"):
        cur.execute("select update_something(1, 2)")
        con.commit()
    if st.button("2->1"):
        cur.execute("select update_something(2, 1)")
        con.commit()
    show_table("select * from nodes where device_count = 2")
    show_table("select * from nodes where device_count = 1")

if st.checkbox("8. System stored procedure"):
    st.write("Current database, current user, current schema")
    show_table("select current_database(), current_user, current_schema();")

if st.checkbox("9. Create table"):
    create_table = st.text_area("Create table query", "create table test(id int);")
    if st.button("Create table"):
        cur.execute(create_table)
        con.commit()
        st.success("Table created")

if st.checkbox("10. Query"):
    query = st.text_area("Insert query", "insert into test values(1);")
    if st.button("Execute query"):
        show_table(query)
        con.commit()
        st.success("Executed")