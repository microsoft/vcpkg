#pragma once

#define NOMINMAX
#define WIN32_LEAN_AND_MEAN

#include <windows.h>

#ifdef _WIN32
#include <process.h>
#include <shellapi.h>
#include <shlobj.h>
#include <windows.h>
#include <winhttp.h>
#endif

#ifdef __linux__
#include <limits.h>
#include <pwd.h>
#include <string.h> //for strcasecmp
#include <sys/types.h>
#include <sys/utsname.h> //utsname
#include <unistd.h>
#endif

#if defined(_WIN32)
#define VCPKG_STRCASECMP _stricmp
#define VCPKG_MAX_PATH _MAX_PATH
#else
#define VCPKG_STRCASECMP strcasecmp
#define VCPKG_MAX_PATH PATH_MAX
#endif

#include <algorithm>
#include <array>
#include <cassert>
#include <cctype>
#include <chrono>
#include <codecvt>
#include <cstdarg>
#include <cstddef>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <functional>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <map>
#include <memory>
#include <regex>
#include <set>
#include <stdexcept>
#include <string>
#include <sys/timeb.h>
#include <system_error>
#include <time.h>
#include <type_traits>
#include <unordered_map>
#include <unordered_set>
#include <utility>
#include <vector>
