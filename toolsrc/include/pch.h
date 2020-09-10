#pragma once

#include <vcpkg/base/system_headers.h>

#include <vcpkg/base/files.h>
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
