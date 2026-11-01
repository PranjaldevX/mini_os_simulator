# mini_os_simulator build file
# Usage: make | make clean
# CI passes EXTRA_FLAGS=-Werror to turn warnings into errors.

COMPILER         := g++
WARNING_FLAGS    := -Wall -Wextra -Wpedantic
COMPILE_FLAGS    := -std=c++17 -O2 -g $(WARNING_FLAGS) -MMD -MP -Iinclude $(EXTRA_FLAGS)

SOURCE_DIRECTORY := src
BUILD_DIRECTORY  := build
PROGRAM_PATH     := $(BUILD_DIRECTORY)/mini_os_simulator

SOURCE_FILES     := $(wildcard $(SOURCE_DIRECTORY)/*.cpp)
OBJECT_FILES     := $(patsubst $(SOURCE_DIRECTORY)/%.cpp,$(BUILD_DIRECTORY)/%.o,$(SOURCE_FILES))
DEPENDENCY_FILES := $(OBJECT_FILES:.o=.d)

.PHONY: all clean

all: $(PROGRAM_PATH)

$(PROGRAM_PATH): $(OBJECT_FILES)
	$(COMPILER) $(OBJECT_FILES) -o $@ $(EXTRA_FLAGS)

$(BUILD_DIRECTORY)/%.o: $(SOURCE_DIRECTORY)/%.cpp
	@mkdir -p $(BUILD_DIRECTORY)
	$(COMPILER) $(COMPILE_FLAGS) -c $< -o $@

-include $(DEPENDENCY_FILES)

clean:
	rm -rf $(BUILD_DIRECTORY)

# ---- tests ----
# Every tests/test_*.cpp becomes build/test_* and is linked with all of src/ except main.cpp.

TEST_DIRECTORY  := tests
TEST_SOURCES    := $(wildcard $(TEST_DIRECTORY)/test_*.cpp)
TEST_PROGRAMS   := $(patsubst $(TEST_DIRECTORY)/%.cpp,$(BUILD_DIRECTORY)/%,$(TEST_SOURCES))
LIBRARY_OBJECTS := $(filter-out $(BUILD_DIRECTORY)/main.o,$(OBJECT_FILES))

.PHONY: test

$(BUILD_DIRECTORY)/test_%: $(TEST_DIRECTORY)/test_%.cpp $(LIBRARY_OBJECTS)
	@mkdir -p $(BUILD_DIRECTORY)
	$(COMPILER) $(COMPILE_FLAGS) $< $(LIBRARY_OBJECTS) -o $@ $(EXTRA_FLAGS)

test: $(TEST_PROGRAMS)
	@for test_program in $(TEST_PROGRAMS); do \
	    echo "== running $$test_program"; \
	    $$test_program || exit 1; \
	done

-include $(TEST_PROGRAMS:=.d)

# ---- sanitizers ----
# Rebuilds into build/sanitize with ASan + UBSan, then runs all tests.

.PHONY: sanitize

sanitize:
	$(MAKE) test BUILD_DIRECTORY=build/sanitize EXTRA_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer"

# ---- formatting ----
# make format        rewrites files to match .clang-format
# make format-check  fails if any file is not formatted (used by CI)

FORMAT_FILES := $(wildcard $(SOURCE_DIRECTORY)/*.cpp include/*.h $(TEST_DIRECTORY)/*.cpp $(TEST_DIRECTORY)/*.h)

.PHONY: format format-check

format:
	clang-format -i $(FORMAT_FILES)

format-check:
	clang-format --dry-run --Werror $(FORMAT_FILES)
