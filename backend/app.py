import os

import psycopg2
import psycopg2.extras
from flask import Flask, jsonify, request

from matcher import rank_jobs

app = Flask(__name__)


def get_conn():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        connect_timeout=5,
    )


def fetch_jobs():
    conn = get_conn()
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute("SELECT id, title, company, required_skills FROM jobs ORDER BY id")
            return cur.fetchall()
    finally:
        conn.close()


@app.get("/health")
def health():
    return "ok", 200


@app.get("/jobs")
def jobs():
    return jsonify(fetch_jobs())


@app.post("/match")
def match():
    data = request.get_json(silent=True) or {}
    skills = data.get("skills")
    if not isinstance(skills, list) or not skills:
        return jsonify({"error": "skills must be a non-empty list"}), 400
    skills = [s for s in skills if isinstance(s, str)]
    return jsonify(rank_jobs(skills, fetch_jobs()))
