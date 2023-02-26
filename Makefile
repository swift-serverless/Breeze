linux_test:
	docker-compose -f docker/docker-compose.yml run test

localstack:
	docker run -it --rm -p "4566:4566" localstack/localstack