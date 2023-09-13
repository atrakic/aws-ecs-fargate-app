from datetime import datetime
import os
import boto3

table = os.environ.get("TABLE_NAME")

dynamodb = boto3.client("dynamodb")
cloudwatch = boto3.client("cloudwatch")


def list_tables():
    return dynamodb.list_tables()


def get_items():
    log_metric("PageViews", table, 1)
    return dynamodb.scan(TableName=table)


def log_metric(metric_name, namespace, value):
    # Send custom metric to CloudWatch
    cloudwatch.put_metric_data(
        Namespace=namespace,
        MetricData=[
            {
                "MetricName": metric_name,
                "Value": value,
                "Unit": "Count",
                "Timestamp": datetime.now(),
            }
        ],
    )
