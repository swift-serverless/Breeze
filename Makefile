SWIFT_BIN_PATH = $(shell swift build --show-bin-path)

linux_test:
	docker-compose -f docker/docker-compose.yml run --rm test

linux_shell:
	docker-compose -f docker/docker-compose.yml run --rm shell

build_no_cache:
	docker-compose -f docker/docker-compose.yml build --no-cache

composer_up:
	docker-compose -f docker/docker-compose.yml up

composer_down:
	docker-compose -f docker/docker-compose.yml down

localstack:
	docker run -it --rm -p "4566:4566" localstack/localstack

test:
	swift test --sanitize=thread --enable-code-coverage

coverage:
	llvm-cov export $(SWIFT_BIN_PATH)/BreezePackageTests.xctest \
		--instr-profile=$(SWIFT_BIN_PATH)/codecov/default.profdata \
		--format=lcov > $(SWIFT_BIN_PATH)/lcov.info

upload_coverage:
	bash <(curl -s https://codecov.io/bash) -f $(SWIFT_BIN_PATH)/codecov/lcov.info
