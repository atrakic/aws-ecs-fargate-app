import logging
import os
import sys

# import json


logging.basicConfig(stream=sys.stdout, level=logging.INFO)

# import aws_sqs as aws_sqs
# import aws_dynamodb as aws_dynamodb
# import aws_sns as aws_sns

# queue_url = os.getenv("QUEUE_URL", "http://localhost:4566/000000000000/flask-app")
topic_arn = os.getenv("TOPIC_ARN", "http://localhost:4566/000000000000/flask-app")


def process_message():
    logging.info("Message sent to %s", topic_arn)


if __name__ == "__main__":
    while True:
        process_message()
