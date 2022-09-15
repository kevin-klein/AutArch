import psycopg2
import psycopg2.pool
import psycopg2.extras
import os
from flask import g

pool = psycopg2.pool.ThreadedConnectionPool(
    1,
    20,
    user=os.getenv('DB_USER'),
    host='127.0.0.1',
    password=os.getenv('DB_PASSWORD'),
    database=os.getenv('DB_NAME')
)

def get_db():
    conn = pool.getconn()
    conn.autocommit = True

    g.db = psycopg2.extras.RealDictCursor(conn)
    g.conn = conn

    return g.db

def close_connection(e=None):
    db = g.pop('db', None)
    if db is not None:
        db.close()

    conn = g.pop('conn', None)
    if conn is not None:
        pool.putconn(conn)

def init_app(app):
    app.teardown_appcontext(close_connection)
