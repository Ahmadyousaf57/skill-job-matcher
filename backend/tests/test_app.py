import pytest

import app as app_module


@pytest.fixture
def client(monkeypatch):
    monkeypatch.setattr(
        app_module,
        "fetch_jobs",
        lambda: [
            {"id": 1, "title": "A", "company": "X", "required_skills": "python,docker"},
            {"id": 2, "title": "B", "company": "Y", "required_skills": "java,spring"},
        ],
    )
    return app_module.app.test_client()


def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_data(as_text=True) == "ok"


def test_jobs_returns_list(client):
    resp = client.get("/jobs")
    assert resp.status_code == 200
    assert len(resp.get_json()) == 2


def test_match_ranks_best_first(client):
    resp = client.post("/match", json={"skills": ["python", "docker"]})
    data = resp.get_json()
    assert resp.status_code == 200
    assert data[0]["title"] == "A"
    assert data[0]["match_percent"] == 100


def test_match_rejects_empty_skills(client):
    resp = client.post("/match", json={"skills": []})
    assert resp.status_code == 400


def test_match_rejects_missing_body(client):
    resp = client.post("/match")
    assert resp.status_code == 400


class FakeCursor:
    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False

    def execute(self, sql):
        self.sql = sql

    def fetchall(self):
        return [{"id": 1, "title": "A", "company": "X", "required_skills": "python"}]


class FakeConn:
    closed = False

    def cursor(self, cursor_factory=None):
        return FakeCursor()

    def close(self):
        FakeConn.closed = True


def test_fetch_jobs_uses_db_and_closes(monkeypatch):
    for key in ("DB_HOST", "DB_NAME", "DB_USER", "DB_PASSWORD"):
        monkeypatch.setenv(key, "x")
    monkeypatch.setattr(app_module.psycopg2, "connect", lambda **kwargs: FakeConn())
    rows = app_module.fetch_jobs()
    assert rows[0]["title"] == "A"
    assert FakeConn.closed
