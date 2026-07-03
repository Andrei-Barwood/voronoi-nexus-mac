# Makefile for affine-replica

BINARY = affine-replica
BUILD_DIR = .build
RELEASE = $(BUILD_DIR)/release/$(BINARY)

.PHONY: all build release clean run-sample run-json universal

all: release

build:
	swift build

release:
	swift build -c release

run-sample:
	swift run $(BINARY) analyze --sample

run-json:
	swift run $(BINARY) analyze --sample --json

# Universal binary (Apple Silicon + Intel)
universal: release
	@echo "Building universal binary..."
	lipo -create \
		$(BUILD_DIR)/arm64-apple-macosx/release/$(BINARY) \
		$(BUILD_DIR)/x86_64-apple-macosx/release/$(BINARY) \
		-output $(BINARY)-universal || \
	(echo "Note: lipo requires building with --arch arm64 --arch x86_64 separately"; \
	 swift build -c release --arch arm64 --arch x86_64 && \
	 cp $(BUILD_DIR)/apple/Products/Release/$(BINARY) $(BINARY)-universal)
	@chmod +x $(BINARY)-universal
	@echo "Created: $(BINARY)-universal"

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(BINARY)-universal

test:
	swift test || true
