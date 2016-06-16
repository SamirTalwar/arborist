PRODUCTION_FILES = $(shell find src -name '*.elm')
TEST_FILES = $(shell find test -name '*.elm')

.PHONY: test
test: bin/run.js $(PRODUCTION_FILES) $(TEST_FILES)
	node bin/run.js $(TEST_FILES)

node_modules: package.json
	npm install
