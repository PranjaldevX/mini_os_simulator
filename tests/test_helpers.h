#pragma once

#include <iostream>

// Tiny test helpers, standard library only (SRS 2.4).
// A failed check prints file:line and keeps going, so one run shows every failure.

inline int totalCheckCount = 0;
inline int failedCheckCount = 0;

#define CHECK(condition)                                                                          \
    do {                                                                                          \
        ++totalCheckCount;                                                                        \
        if (!(condition)) {                                                                       \
            ++failedCheckCount;                                                                   \
            std::cerr << __FILE__ << ":" << __LINE__ << ": CHECK failed: " << #condition << "\n"; \
        }                                                                                         \
    } while (false)

#define CHECK_EQUAL(actual, expected)                                                       \
    do {                                                                                    \
        ++totalCheckCount;                                                                  \
        const auto actualValueForCheck = (actual);                                          \
        const auto expectedValueForCheck = (expected);                                      \
        if (!(actualValueForCheck == expectedValueForCheck)) {                              \
            ++failedCheckCount;                                                             \
            std::cerr << __FILE__ << ":" << __LINE__ << ": CHECK_EQUAL failed: " << #actual \
                      << "\n"                                                               \
                      << "    expected: " << expectedValueForCheck << "\n"                  \
                      << "    actual:   " << actualValueForCheck << "\n";                   \
        }                                                                                   \
    } while (false)

inline int reportTestResults() {
    std::cout << totalCheckCount << " checks, " << failedCheckCount << " failed\n";
    return failedCheckCount == 0 ? 0 : 1;
}
