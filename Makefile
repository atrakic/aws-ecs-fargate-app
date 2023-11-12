MAKEFLAGS += --silent

BASEDIR=$(shell git rev-parse --show-toplevel)

APP ?= flask-app

.PHONY: all test clean

all: docker test clean

docker:
	docker-compose -f ${BASEDIR}/src/compose.yml up --build --no-deps --remove-orphans -d
	while ! \
	[[ "$$(docker inspect --format "{{json .State.Health }}" $(APP) | jq -r ".Status")" == "healthy" ]];\
	do \
		echo "waiting for $(APP) ..."; \
		sleep 1; \
	done
	curl --connect-timeout 5 --retry 5 --retry-delay 0 --retry-max-time 60 http://localhost:8000/
	docker-compose -f ${BASEDIR}/src/compose.yml down --remove-orphans -v --rmi local

export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_DEFAULT_REGION="us-east-1"

test:
	cp -f ${BASEDIR}/tests/localstack/versions.tf ${BASEDIR}/terraform/versions.tf
	docker-compose -f ${BASEDIR}/tests/localstack/compose.yml up -d
	${BASEDIR}/scripts/terraform.sh

clean:
	${BASEDIR}/scripts/terraform.sh clean
	docker-compose -f ${BASEDIR}/tests/localstack/compose.yml down --remove-orphans -v --rmi local
	git checkout ${BASEDIR}/terraform/versions.tf
