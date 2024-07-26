import json
import requests


def test_insert_multiple_items():
    # Read the sample JSON file
    with open("tests/sample.json") as f:
        data = json.load(f)

    # Send a POST request to the /add endpoint
    response = requests.post("http://127.0.0.1:8000/add", json=data)

    # Check the response status code
    assert response.status_code == 200

    # Check the response content
    response_data = response.json()
    assert response_data["message"] == "success"
    assert len(response_data["inserted_items"]) == len(data["items"])


if __name__ == "__main__":
    test_insert_multiple_items()
