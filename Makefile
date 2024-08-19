MAKEFLAGS += --silent

BASEDIR=$(shell git rev-parse --show-toplevel)

APP ?= publisher

.PHONY: all terraform test docker clean healthcheck

all: terraform

terraform:
	${BASEDIR}/scripts/terraform.sh

docker:
	docker compose up --build --no-deps --remove-orphans -d
	while ! \
	[[ "$$(docker inspect --format "{{json .State.Health }}" $(APP) | jq -r ".Status")" == "healthy" ]];\
	do \
		echo "waiting for $(APP) ..."; \
		sleep 1; \
	done
	curl --connect-timeout 5 --retry 5 --retry-delay 0 --retry-max-time 60 http://localhost:8000/

%:
	docker compose up --build --force-recreate --no-color $@ -d

healthcheck:
	docker inspect $(APP) --format "{{ (index (.State.Health.Log) 0).Output }}"

test: docker
	export AWS_DEFAULT_REGION=us-east-1
	export AWS_ACCESS_KEY_ID=test
	export AWS_SECRET_ACCESS_KEY=test
	cp -f ${BASEDIR}/tests/fixtures/localstack.tf ${BASEDIR}/terraform/versions.tf
	cp -f ${BASEDIR}/tests/fixtires/fixtures.tfvars ${BASEDIR}/terraform/terraform.tfvars
	${BASEDIR}/scripts/terraform.sh
	${BASEDIR}/tests/test.sh
	pytest -v
	make clean

clean:
	# Skip terraform destroy for now
	##${BASEDIR}/scripts/terraform.sh clean
	rm -rf ${BASEDIR}/terraform/terraform.tfstate*
	rm -rf ${BASEDIR}/terraform/*.tfplan
	#rm -rf ${BASEDIR}/terraform/.terraform
	git checkout ${BASEDIR}/terraform/versions.tf
	docker compose down --remove-orphans -v --rmi local

-include .env include.mk
