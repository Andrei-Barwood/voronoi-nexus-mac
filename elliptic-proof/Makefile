BINARY = elliptic-proof

.PHONY: build release clean run-sample

build:
	swift build

release:
	swift build -c release

run-sample:
	swift run $(BINARY) analyze --sample

clean:
	rm -rf .build
