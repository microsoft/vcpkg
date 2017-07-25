#pragma once

#define NOMINMAX
#define WIN32_LEAN_AND_MEAN

#include <windows.h>

#ifdef _WIN32
#include <windows.h>
#include <process.h>
#include <shellapi.h>
#include <shlobj.h>
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

#ifndef _MAX_PATH
#define _MAX_PATH PATH_MAX
#endif

#ifdef _WIN32
#define strcasecmp _stricmp
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
