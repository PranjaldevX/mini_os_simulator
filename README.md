# Mini OS Simulator

A C++17 console simulator that combines CPU scheduling, paging,
disk scheduling and synchronization in one time-stepped system.

Status: under development. Requirements are in docs/SRS.md.

## Requirements

Primary environment: Ubuntu on WSL2.

    sudo apt install -y build-essential clang-format

## Build and run

    make
    ./build/mini_os_simulator

## Test

    make test        # run all tests
    make sanitize    # run tests under AddressSanitizer and UndefinedBehaviorSanitizer

## Formatting

    make format        # reformat files in place
    make format-check  # fail if any file is not formatted (CI runs this)

## Layout

    include/   headers
    src/       implementation, main.cpp is the entry point
    tests/     one test program per module (tests/test_*.cpp)
    docs/      SRS, design notes and decision records

## Workflow

Work happens on short-lived branches and reaches `main` through a pull
request. Commit messages follow Conventional Commits. CI must pass before
merging.
