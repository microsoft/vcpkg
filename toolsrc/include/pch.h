#pragma once

#include <vcpkg/pragmas.h>

#if defined(_WIN32)
#define NOMINMAX
#define WIN32_LEAN_AND_MEAN

#pragma warning(suppress : 4768)
#include <windows.h>

#pragma warning(suppress : 4768)
#include <Shlobj.h>

#include <process.h>
#include <shellapi.h>
#include <winhttp.h>
#else
#include <unistd.h>
#endif

#include <algorithm>
#include <array>
#include <atomic>
#include <cassert>
#include <cctype>
#include <chrono>
#include <codecvt>
#include <cstdarg>
#include <cstddef>
#include <cstdint>
#define _SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING
#include <cstring>
#if VCPKG_USE_STD_FILESYSTEM
#include <filesystem>
#else
#include <experimental/filesystem>
#endif
#include <fstream>
#include <functional>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <map>
#include <memory>
#include <mutex>
#include <random>
#include <regex>
#include <set>
#include <stdexcept>
#include <string>
#if defined(_WIN32)
#include <sys/timeb.h>
#else
#include <sys/time.h>
#endif

#include <sys/types.h>
// glibc defines major and minor in sys/types.h, and should not
#undef major
#undef minor

#include <system_error>
#include <thread>
#include <time.h>
#include <type_traits>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>
