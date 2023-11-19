import os
import requests


def healthcheck():
    port = os.environ.get("PORT", "8000")
    url = f"http://0.0.0.0:{port}/healthcheck"
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            print("Healthcheck passed")
        else:
            print("Healthcheck failed")
    except requests.exceptions.RequestException as e:
        print("Healthcheck failed:", str(e))


if __name__ == "__main__":
    healthcheck()
