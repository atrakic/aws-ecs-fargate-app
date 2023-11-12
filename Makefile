MAKEFLAGS += --silent

BASEDIR=$(shell git rev-parse --show-toplevel)

APP ?= flask-app

.PHONY: all test clean

export AWS_DEFAULT_PROFILE=e2e

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

test:
	${BASEDIR}/scripts/terraform.sh

clean:
	${BASEDIR}/scripts/terraform.sh clean
