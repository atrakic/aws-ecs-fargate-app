aws dynamodb describe-endpoints
aws dynamodb create-table --cli-input-json file://create-table.json
aws dynamodb list-tables
aws dynamodb batch-write-item --request-items file://batch-write.json
