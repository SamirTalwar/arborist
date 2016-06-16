PRODUCTION_FILES = $(shell find src -name '*.elm')
PRODUCTION_NATIVE_FILES = src/Native/Arborist/Framework.js
TEST_FILES = $(shell find test -name '*.elm')

.PHONY: test
test: src/run.js $(PRODUCTION_FILES) $(PRODUCTION_NATIVE_FILES) $(TEST_FILES)
	node src/run.js $(TEST_FILES)

node_modules: package.json
	npm install
