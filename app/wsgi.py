import os

from publisher import app

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=os.environ.get("PORT"))
