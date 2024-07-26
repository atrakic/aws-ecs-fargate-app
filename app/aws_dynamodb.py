import boto3


dynamodb = boto3.client("dynamodb")


def list_dynamodb_tables():
    return dynamodb.list_tables()


def get_dynamodb_items(table_name):
    """
    Get all items from a DynamoDB table using a scan operation.
    """
    response = dynamodb.scan(TableName=table_name)
    return response.get("Items", [])


def get_dynamodb_items_paginated(table_name):
    """
    Get all items from a DynamoDB table using a paginated scan operation.
    """
    items = []
    last_evaluated_key = None

    while True:
        if last_evaluated_key:
            response = dynamodb.scan(
                TableName=table_name, ExclusiveStartKey=last_evaluated_key
            )
        else:
            response = dynamodb.scan(TableName=table_name)

        items.extend(response.get("Items", []))
        last_evaluated_key = response.get("LastEvaluatedKey")

        if not last_evaluated_key:
            break

    return items


def put_dynamodb_item(table_name, item):
    return dynamodb.put_item(TableName=table_name, Item=item)
