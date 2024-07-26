import json
import requests


def test_health_check():
    response = requests.get("http://127.0.0.1:8000/healthcheck", timeout=5)
    assert response.status_code == 200


def test_get_all_items():
    response = requests.get("http://127.0.0.1:8000/getall", timeout=5)
    assert response.status_code == 200


def test_insert_multiple_items():
    with open("tests/sample.json", encoding="utf-8") as f:
        data = json.load(f)

    # Send a POST request to the /add endpoint
    response = requests.post("http://127.0.0.1:8000/add", json=data, timeout=5)

    # Check the response status code
    assert response.status_code == 200

    # Check the response content
    response_data = response.json()
    assert response_data["message"] == "success"
    # assert len(response_data["inserted_items"]) == len(data["items"])


if __name__ == "__main__":
    test_insert_multiple_items()
    test_get_all_items()
    test_health_check()
