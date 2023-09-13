from flask import Flask, request, jsonify
import aws_controller

app = Flask(__name__)


@app.route("/")
def index():
    resp = {
        "host": request.headers["Host"],
        "user-agent": request.headers["User-Agent"],
    }
    return jsonify(resp)


@app.route("/get-items")
def get_items():
    return jsonify(aws_controller.get_items())


@app.route("/health")
def health_check():
    return jsonify(aws_controller.list_tables())
