#pragma once

#define NOMINMAX
#define WIN32_LEAN_AND_MEAN
#pragma warning(suppress : 4768)
#include <windows.h>

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
#include <filesystem>
#include <fstream>
#include <functional>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <map>
#include <memory>
#include <mutex>
#include <process.h>
#include <regex>
#include <set>
#include <shellapi.h>
#pragma warning(push)
#pragma warning(disable : 4768)
#include <Shlobj.h>
#pragma warning(pop)
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
#include <winhttp.h>
