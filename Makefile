PRODUCTION_FILES = $(shell find src -name '*.elm')
TEST_FILES = $(shell find test -name '*.elm')
END_TO_END_TEST_FILES = $(shell find test/end-to-end -type f)
SMOKE = ./Smoke/bin/smoke

build/arborist.js: $(PRODUCTION_FILES)
	mkdir -p build
	elm make --warn --yes --docs=elm-stuff/documentation.json --output=$@ $^

.PHONY: test unit-test end-to-end-test

test: unit-test end-to-end-test

unit-test: bin/run build/arborist.js $(TEST_FILES)
	bin/run $(TEST_FILES)

end-to-end-test: bin/run build/arborist.js $(SMOKE) $(END_TO_END_TEST_FILES)
	$(SMOKE) bin/run test/end-to-end

$(SMOKE):
	git submodule update --init Smoke
