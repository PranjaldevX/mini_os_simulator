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
