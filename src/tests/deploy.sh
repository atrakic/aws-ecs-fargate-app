aws dynamodb create-table --cli-input-json file://create-table.json
aws dynamodb batch-write-item --request-items file://batch-write.json
