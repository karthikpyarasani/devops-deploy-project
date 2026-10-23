from app import app


def test_health():
    client = app.test_client()
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_home_counts_visits():
    client = app.test_client()
    first = client.get("/").get_json()["visits"]
    second = client.get("/").get_json()["visits"]
    assert second == first + 1
