import psycopg2
import os
import dotenv

dotenv.load_dotenv()
POSTGRES_PWD = os.getenv('POSTGRES_PASSWORD')

conn = psycopg2.connect(database = "postgres", user="postgres", password=POSTGRES_PWD, host = "localhost", port = "5432")
print("Opened database successfully")

cur = conn.cursor()
cur.execute('''CREATE TABLE COMPANY
      (ID INT PRIMARY KEY     NOT NULL,
      NAME           TEXT    NOT NULL,
      AGE            INT     NOT NULL,
      ADDRESS        CHAR(50),
      SALARY         REAL);''')
print("Table created successfully")

conn.commit()
conn.close()

print("all done!")