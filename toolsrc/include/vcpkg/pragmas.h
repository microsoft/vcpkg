#pragma once

#if defined(_MSC_VER) && _MSC_VER < 1911
// [[nodiscard]] is not recognized before VS 2017 version 15.3
#pragma warning(disable : 5030)
#endif

#if defined(_MSC_VER) && _MSC_VER < 1910
// https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-3-c4800?view=vs-2019
#pragma warning(disable : 4800)
#endif

#if defined(__GNUC__) && __GNUC__ < 7
// [[nodiscard]] is not recognized before GCC version 7
#pragma GCC diagnostic ignored "-Wattributes"
#endif
