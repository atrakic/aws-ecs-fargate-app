import os
import sys
import json
import uuid
import logging
from datetime import datetime

from flask import Flask, request, jsonify, Response

import aws_dynamodb
import aws_sts
import aws_sns

TABLE = os.environ.get("TABLE_NAME", "example")
# TOPIC_ARN = os.environ.get("TOPIC_ARN",
#     "arn:aws:sqs:us-east-1:000000000000:flask-app")

app = Flask(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.INFO)


@app.route("/")
def index():
    resp = {
        "host": request.headers["Host"],
        "user-agent": request.headers["User-Agent"],
        "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    }
    return jsonify(resp)


@app.route("/healthcheck")
def health_check():
    return jsonify(aws_sts.aws_whoami())


@app.route("/add", methods=["POST"])
def put_items():
    content = request.json
    try:
        items = content.get("items", [])
        for item in items:
            unique_id = str(uuid.uuid4())
            artist = item["artist"]
            title = item["title"]
            aws_dynamodb.put_dynamodb_item(
                TABLE,
                {
                    "id": {"S": unique_id},
                    "artist": {"S": artist},
                    "title": {"S": title},
                },
            )
            # inserted_items.append({"artist": artist, "title": title})
            logging.info("Item: %s added to db successfully", content)

            # # TODO: Publish message to SNS topic
            # aws_sns.publish_message(
            #     topic_arn=TOPIC_ARN,
            #     message=json.dumps(
            #         {
            #             "artist": artist,
            #             "title": title,
            #         }
            #     ),
            # )
            # logging.info("Published message to topic: %s.", TOPIC_ARN)

    except KeyError as e:
        error_message = json.dumps({"Message": str(e)})
        return Response(error_message, status=401, mimetype="application/json")

    return jsonify(message="success", status=200)


@app.route("/getall")
def get_items():
    return jsonify(aws_dynamodb.get_dynamodb_items_paginated(TABLE))
