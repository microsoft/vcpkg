#pragma once

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
#if defined(_WIN32)
#include <filesystem>
#else
#include <experimental/filesystem>
#endif
#include <cstring>
#include <fstream>
#include <functional>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <map>
#include <memory>
#include <mutex>
#include <regex>
#include <set>
#include <stdexcept>
#include <string>
#include <sys/timeb.h>
#include <sys/types.h>
#include <system_error>
#include <thread>
#include <time.h>
#include <type_traits>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>
