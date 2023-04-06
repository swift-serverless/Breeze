SWIFT_BIN_PATH = $(shell swift build --show-bin-path)
EXAMPLE_PATH = ./Example
BUILD_TEMP = .build/temp

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
		--format=lcov > $(GITHUB_WORKSPACE)/lcov.info

install_yq:
	yum -y install wget
	wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
	chmod a+x /usr/local/bin/yq

generate_temp:
	swift run breeze -c ./Sources/BreezeCommand/Resources/breeze.yml -t $(BUILD_TEMP) -f true

generate_example:
	swift run breeze -c ./Sources/BreezeCommand/Resources/breeze.yml -t $(EXAMPLE_PATH) -f true

compare_breeze_output_with_example: install_yq generate_temp
	bash -c "diff <(yq -P 'sort_keys(..)' $(EXAMPLE_PATH)/serverless.yml) <(yq -P 'sort_keys(..)' $(BUILD_TEMP)/serverless.yml)"
	bash -c "diff <(yq -P 'sort_keys(..)' $(EXAMPLE_PATH)/serverless-x86_64.yml) <(yq -P 'sort_keys(..)' $(BUILD_TEMP)/serverless-x86_64.yml)"
	diff -rb $(EXAMPLE_PATH) $(BUILD_TEMP) --exclude=*.yml --exclude=Package.resolved
