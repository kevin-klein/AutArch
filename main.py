from dotenv import load_dotenv
load_dotenv()

import dfg

import time
from flask import Flask
import db

app = Flask(__name__)
db.init_app(app)

@app.route('/publications/index')
def index_publications():
    dfg.index_publications(db.get_db())

    return { 'errorcode': 0 }

@app.route('/publications')
def get_current_time():
    cur = db.get_db()
    cur.execute('select * from publications');
    rows = cur.fetchall()

    return {'publications': rows}
