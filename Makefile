MAKEFLAGS += --silent

BASEDIR=$(shell git rev-parse --show-toplevel)

APP ?= flask-app

.PHONY: all test docker clean healthcheck

all: docker test

docker:
	docker-compose up --build --no-deps --remove-orphans -d
	while ! \
	[[ "$$(docker inspect --format "{{json .State.Health }}" $(APP) | jq -r ".Status")" == "healthy" ]];\
	do \
		echo "waiting for $(APP) ..."; \
		sleep 1; \
	done
	curl --connect-timeout 5 --retry 5 --retry-delay 0 --retry-max-time 60 http://localhost:8000/

%:
	docker-compose up --build --force-recreate --no-color $@ -d

healthcheck:
	docker inspect $(APP) --format "{{ (index (.State.Health.Log) 0).Output }}"

test:
	# workarround since testing without a licence key for localstack
	cp -f ${BASEDIR}/tests/localstack/versions.tf ${BASEDIR}/terraform/versions.tf
	rm -rf ${BASEDIR}/terraform/app.tf
	export AWS_DEFAULT_REGION=us-east-1
	export AWS_ACCESS_KEY_ID=test
	export AWS_SECRET_ACCESS_KEY=test
	${BASEDIR}/scripts/terraform.sh
	${BASEDIR}/tests/test.sh
	pytest -v

clean:
	${BASEDIR}/scripts/terraform.sh clean
	rm -rf ${BASEDIR}/terraform/terraform.tfstate*
	rm -rf ${BASEDIR}/terraform/.terraform
	docker-compose down --remove-orphans -v --rmi local
	git checkout ${BASEDIR}/terraform/versions.tf
	git checkout ${BASEDIR}/terraform/app.tf

-include .env include.mk
