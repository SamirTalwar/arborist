PRODUCTION_FILES = $(shell find src -name '*.elm')
TEST_FILES = $(shell find test-unit -name '*.elm')
SMOKE = ./Smoke/bin/smoke

build/arborist.js: $(PRODUCTION_FILES)
	mkdir -p build
	elm make --warn --yes --docs=elm-stuff/documentation.json --output=$@ $^

.PHONY: test unit-test end-to-end-test

test: unit-test end-to-end-test

unit-test:
	bin/run Test.Arborist.Unit.tests $(TEST_FILES)

end-to-end-test:
	$(SMOKE) bin/run test-end-to-end

$(SMOKE):
	git submodule update --init Smoke
