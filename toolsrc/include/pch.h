#pragma once

#include <vcpkg/base/system_headers.h>

#include <vcpkg/base/pragmas.h>

#if defined(_WIN32)
#include <process.h>
#include <shellapi.h>
#include <winhttp.h>
#endif

#include <math.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include <algorithm>
#include <array>
#include <atomic>
#include <cassert>
#include <cctype>
#include <chrono>
#include <codecvt>

#if VCPKG_USE_STD_FILESYSTEM
#include <filesystem>
#else
#define _SILENCE_EXPERIMENTAL_FILESYSTEM_DEPRECATION_WARNING
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

#include <time.h>

#include <system_error>
#include <thread>
#include <type_traits>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>
