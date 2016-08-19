PRODUCTION_FILES = $(shell find src -name '*.elm')
TEST_FILES = $(shell find test-unit -name '*.elm')
SMOKE = ./Smoke/bin/smoke

build/arborist.js: $(PRODUCTION_FILES)
	mkdir -p build
	elm make --warn --yes --docs=elm-stuff/documentation.json --output=$@ $^

.PHONY: clean
clean:
	rm -rf build elm-stuff/build-artifacts

.PHONY: check
check: test lint

.PHONY: test
test: unit-test end-to-end-test

.PHONY: unit-test
unit-test:
	bin/run Test.Arborist.Unit.tests $(TEST_FILES)

.PHONY: end-to-end-test
end-to-end-test:
	$(SMOKE) bin/run test-end-to-end

.PHONY: lint
lint:
	./node_modules/.bin/standard bin/run

$(SMOKE):
	git submodule update --init Smoke
