import json
from datetime import datetime

from flask import Flask, request, jsonify
import aws_controller

app = Flask(__name__)


@app.route("/")
def index():
    resp = {
        "host": request.headers["Host"],
        "user-agent": request.headers["User-Agent"],
        "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }
    return jsonify(resp)


@app.route("/add", methods=["POST"])
def put_items():
    content = request.json
    try:
        artist = content["artist"]
        title = content["title"]
        aws_controller.put_item(
            {
                "artist": {"S": artist},
                "title": {"S": title},
            }
        )
    except KeyError as E:
        raise ValidationError("Invalid request " + E.args[0])
        error_message = dumps({"Message": "Cannot use this request"})
        abort(Response(error_message, 401))

    return jsonify(message="success", status=200)


@app.route("/getall")
def get_items():
    return jsonify(aws_controller.get_items())


@app.route("/healthcheck")
def health_check():
    return jsonify(aws_controller.list_tables())
