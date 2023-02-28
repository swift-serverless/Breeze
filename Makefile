linux_test:
	docker-compose -f docker/docker-compose.yml run --rm test

build_no_cache:
	docker-compose -f docker/docker-compose.yml build --no-cache

up:
	docker-compose -f docker/docker-compose.yml up

down:
	docker-compose -f docker/docker-compose.yml down

localstack:
	docker run -it --rm -p "4566:4566" localstack/localstack