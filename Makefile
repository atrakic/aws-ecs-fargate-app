all:
	./deploy.sh

clean:
	terraform -chdir=infra destroy

output:
	terraform -chdir=infra output

docker-test:
	docker-compose -f src/compose.yml up --build --no-deps --remove-orphans -d
	curl --connect-timeout 5 --retry 5 --retry-delay 0 --retry-max-time 60 http://localhost:8000/
	#docker inspect flask-app --format "{{ (index (.State.Health.Log) 0).Output }}"
	docker-compose -f src/compose.yml down --remove-orphans -v
	popd
