import os
import boto3

TABLE = os.environ.get("TABLE_NAME")

dynamodb = boto3.client("dynamodb")


def list_tables():
    return dynamodb.list_tables()


def get_items():
    return dynamodb.scan(TableName=TABLE)


def put_item(item):
    return dynamodb.put_item(TableName=TABLE, Item=item)
