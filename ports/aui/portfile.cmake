vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aui-framework/aui
    REF "v${VERSION}"
    SHA512 decac6cebb6003791896e8d7a9fd7334351aa30205eac787cdbb51d1da657cda140178e0b8f5d236b42a4c1f37633141fb869784e5fc5c9718b5396e077afe7d
    HEAD_REF master
    PATCHES
        debundle.patch
)

vcpkg_replace_string(
    "${SOURCE_PATH}/cmake/aui.build.cmake"
    [[macro(aui_enable_tests AUI_MODULE_NAME)
    if (NOT CMAKE_CROSSCOMPILING)]]
    [[macro(aui_enable_tests AUI_MODULE_NAME)
    if (0)]]
)
vcpkg_replace_string(
    "${SOURCE_PATH}/cmake/aui.build.cmake"
    [[macro(aui_enable_benchmarks AUI_MODULE_NAME)
    if (NOT CMAKE_CROSSCOMPILING)]]
    [[macro(aui_enable_benchmarks AUI_MODULE_NAME)
    if (0)]]
)

# fmt 12+ compatibility fixes
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.core/src/AUI/Common/AString.h"
    [[#include <iostream>]]
    [[#include <iostream>
#include <cstring>]]
)
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.core/src/AUI/Common/AString.h"
    [[template <> struct fmt::detail::is_string<AString>: std::false_type {};]]
    ""
)
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.core/src/AUI/Common/AByteBufferView.h"
    [[lhs.write(buf, std::distance(std::begin(buf), fmt::format_to(buf, " {:02x}", b)));]]
    [[lhs.write(buf, std::distance(std::begin(buf), fmt::format_to(std::begin(buf), " {:02x}", b)));]]
)

# fmt 12+ removed automatic enum formatting; convert enums to underlying type
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.core/src/AUI/Traits/strings.h"
    [[        template<typename T>
        struct fmt<T, std::enable_if_t<std::is_base_of_v<AString, T>>> {
            template<typename T2>
            static decltype(auto) process(T2&& arg) {
                return arg.toStdString();
            }
        };]]
    [[        template<typename T>
        struct fmt<T, std::enable_if_t<std::is_base_of_v<AString, T>>> {
            template<typename T2>
            static decltype(auto) process(T2&& arg) {
                return arg.toStdString();
            }
        };

        template<typename T>
        struct fmt<T, std::enable_if_t<std::is_enum_v<T>>> {
            static auto process(T arg) {
                return static_cast<std::underlying_type_t<T>>(arg);
            }
        };]]
)

# GLM 1.0+ moved translate/rotate to separate header
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.views/src/AUI/Render/IRenderer.h"
    [[#include <glm/glm.hpp>]]
    [[#include <glm/glm.hpp>
#include <glm/ext/matrix_transform.hpp>]]
)

# Add fmt formatter for AMetric (missing in fmt 12+)
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.views/src/AUI/Util/AMetric.h"
    [[#include <AUI/Core.h>
#include <type_traits>
#include <ostream>
#include <tuple>
#include "AUI/Util/Assert.h"]]
    [[#include <AUI/Core.h>
#include <type_traits>
#include <ostream>
#include <tuple>
#include "AUI/Util/Assert.h"
#include <fmt/core.h>]]
)
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.views/src/AUI/Util/AMetric.h"
    [[    return o;
}]]
    [[    return o;
}

template <> struct fmt::formatter<AMetric> : fmt::formatter<float> {
    auto format(AMetric val, fmt::format_context& ctx) const {
        return fmt::formatter<float>::format(static_cast<float>(val), ctx);
    }
};]]
)

# Add fmt formatter for ranged_number (missing in fmt 12+)
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.core/src/AUI/Traits/values.h"
    [[#include <glm/glm.hpp>
#include <AUI/Common/SharedPtrTypes.h>]]
    [[#include <glm/glm.hpp>
#include <AUI/Common/SharedPtrTypes.h>
#include <fmt/core.h>]]
)
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.core/src/AUI/Traits/values.h"
    [[using float_within_0_1 = ranged_number<float, 0, 1>;
}   // namespace aui]]
    [[using float_within_0_1 = ranged_number<float, 0, 1>;
}   // namespace aui

template <typename UnderlyingType, auto min, auto max>
struct fmt::formatter<aui::ranged_number<UnderlyingType, min, max>> : fmt::formatter<UnderlyingType> {
    auto format(aui::ranged_number<UnderlyingType, min, max> val, fmt::format_context& ctx) const {
        return fmt::formatter<UnderlyingType>::format(static_cast<UnderlyingType>(val), ctx);
    }
};]]
)

# GLM 1.0+ moved ortho to separate header
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.views/src/AUI/GL/OpenGLRenderer.cpp"
    [[#include "glm/fwd.hpp"]]
    [[#include "glm/fwd.hpp"
#include <glm/ext/matrix_clip_space.hpp>]]
)
vcpkg_replace_string(
    "${SOURCE_PATH}/aui.views/src/AUI/Platform/AGLEmbedAuiWrap.cpp"
    [[#include "AUI/GL/OpenGLRenderer.h"]]
    [[#include "AUI/GL/OpenGLRenderer.h"
#include <glm/ext/matrix_clip_space.hpp>]]
)

# libbacktrace from vcpkg doesn't provide CMake config; generate one if needed
find_package(libbacktrace CONFIG QUIET)
if(NOT TARGET libbacktrace::libbacktrace)
    file(WRITE "${SOURCE_PATH}/libbacktraceConfig.cmake"
[[if(TARGET libbacktrace::libbacktrace)
    return()
endif()

find_library(LIBBACKTRACE_LIBRARY NAMES backtrace libbacktrace REQUIRED)
find_path(LIBBACKTRACE_INCLUDE_DIR backtrace.h REQUIRED)

add_library(libbacktrace::libbacktrace STATIC IMPORTED)
set_target_properties(libbacktrace::libbacktrace PROPERTIES
    IMPORTED_LOCATION "${LIBBACKTRACE_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${LIBBACKTRACE_INCLUDE_DIR}"
)
]])
endif()

# Use patched aui-config.cmake.in template for vcpkg layout (correct paths, no aui.build.cmake dependency)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/aui-config.cmake.in" DESTINATION "${SOURCE_PATH}/cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAUI_INSTALL_RUNTIME_DEPENDENCIES=OFF
        -DAUIB_NO_PRECOMPILED=TRUE
        -DAUIB_DISABLE=ON
        -Dlibbacktrace_DIR="${SOURCE_PATH}"
)

vcpkg_cmake_install()

# aui installs its cmake config to the package root; move to share/aui/ for vcpkg_cmake_config_fixup
if(EXISTS "${CURRENT_PACKAGES_DIR}/aui-config.cmake")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/aui")
    file(RENAME "${CURRENT_PACKAGES_DIR}/aui-config.cmake" "${CURRENT_PACKAGES_DIR}/share/aui/aui-config.cmake")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/aui-config.cmake")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share/aui")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/aui-config.cmake" "${CURRENT_PACKAGES_DIR}/debug/share/aui/aui-config.cmake")
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME aui)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/cmake")

# aui installs headers into module-specific directories, not a single include/
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
set(VCPKG_POLICY_ALLOW_EMPTY_FOLDERS enabled)

#vcpkg_cmake_config_fixup(PACKAGE_NAME AudioFile CONFIG_PATH lib/cmake/AudioFile)

#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
#file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
