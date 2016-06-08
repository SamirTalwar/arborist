PRODUCTION_FILES = $(shell find src -name '*.elm')
PRODUCTION_NATIVE_FILES = src/Native/Arborist/Framework.js
TEST_FILES = $(shell find test -name '*.elm')

.PHONY: test
test: build/run.js build/test.js
	node build/run.js

build/test.js: $(PRODUCTION_FILES) $(PRODUCTION_NATIVE_FILES) $(TEST_FILES)
	mkdir -p build
	elm make --warn --yes --output=$@ $(PRODUCTION_FILES) $(TEST_FILES)

build/run.js: src/run.js
	mkdir -p build
	cp -f $< $@

src/Native/Arborist/Framework.js: native/src/Arborist/Framework.js node_modules
	mkdir -p src/Native/Arborist
	./node_modules/.bin/browserify --outfile=$@ $<

node_modules: package.json
	npm install
