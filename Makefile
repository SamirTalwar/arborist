PRODUCTION_FILES = $(shell find src -name '*.elm')
TEST_FILES = $(shell find test -name '*.elm')

build/arborist.js: $(PRODUCTION_FILES)
	mkdir -p build
	elm make --warn --yes --docs=elm-stuff/documentation.json --output=$@ $^

.PHONY: test
test: bin/run build/arborist.js $(TEST_FILES)
	bin/run $(TEST_FILES)
