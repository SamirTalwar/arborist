PRODUCTION_FILES = $(shell find src -name '*.elm')
TEST_FILES = $(shell find test -name '*.elm')

.PHONY: test
test: bin/run $(PRODUCTION_FILES) $(TEST_FILES)
	bin/run $(TEST_FILES)

node_modules: package.json
	npm install
