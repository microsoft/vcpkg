vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lief-project/LIEF
    REF ${VERSION}
    SHA512 7df75fab6c7023e37a6a4d27fac8dcb4200e0235625fc5952bb23cedb2e582a37fb67ee471c1ae953c0b205fd9cca5538a835f65ef80a771f72dc7ff68000ed9
    HEAD_REF master
    PATCHES
        fix-liefconfig-cmake-in.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/third-party")

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "target_link_libraries(LIB_LIEF PRIVATE lief_spdlog)"
    "find_package(fmt CONFIG REQUIRED)\nfind_package(spdlog CONFIG REQUIRED)\ntarget_link_libraries(LIB_LIEF PRIVATE fmt::fmt spdlog::spdlog)"
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "TARGETS LIB_LIEF lief_spdlog"
    "TARGETS LIB_LIEF"
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    [[set(CMAKE_INSTALL_LIBDIR "lib")]]
    [[#set(CMAKE_INSTALL_LIBDIR "lib")]]
)
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "set(CMAKE_INSTALL_LIBDIR      \"lib\")"
    "#[[set(CMAKE_INSTALL_LIBDIR      \"lib\")"
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "set(CMAKE_INSTALL_DATAROOTDIR \"share\")"
    "set(CMAKE_INSTALL_DATAROOTDIR \"share\")]]\nset(CMAKE_INSTALL_INCLUDEDIR  \"include\")"
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "COMPONENT libraries"
    " "
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    [[ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}]]
    " "
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    [[RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}]]
    " "
)

vcpkg_replace_string("${SOURCE_PATH}/src/BinaryStream/BinaryStream.cpp"
    [[#include "third-party/utfcpp.hpp"]]
    [[#include <utf8cpp/utf8.h>]]
)

vcpkg_replace_string("${SOURCE_PATH}/src/utils.cpp"
    [[#include "third-party/utfcpp.hpp"]]
    [[#include <utf8cpp/utf8.h>]]
)

vcpkg_replace_string("${SOURCE_PATH}/src/PE/Builder.cpp"
    [[#include "third-party/utfcpp.hpp"]]
    [[#include <utf8cpp/utf8.h>]]
)

vcpkg_replace_string("${SOURCE_PATH}/src/logging.cpp"
    [[#include "spdlog/fmt/bundled/args.h"]]
    "#include <fmt/args.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/logging.hpp"
    "#include <spdlog/fmt/fmt.h>"
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/utils.cpp"
    "#include <spdlog/fmt/fmt.h>"
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/internal_utils.hpp"
    [[#include "spdlog/fmt/fmt.h"]]
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/PE/Header.cpp"
    "#include <spdlog/fmt/fmt.h>"
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/PE/OptionalHeader.cpp"
    "#include <spdlog/fmt/fmt.h>"
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/PE/TLS.cpp"
    [[#include "spdlog/fmt/fmt.h"]]
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/MachO/BuildVersion.cpp"
    "#include <spdlog/fmt/fmt.h>"
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/MachO/SourceVersion.cpp"
    [[#include "spdlog/fmt/fmt.h"]]
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/MachO/DylibCommand.cpp"
    [[#include "spdlog/fmt/fmt.h"]]
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

vcpkg_replace_string("${SOURCE_PATH}/src/MachO/VersionMin.cpp"
    [[#include "spdlog/fmt/fmt.h"]]
    "#include <spdlog/fmt/fmt.h>\n#include <spdlog/fmt/ranges.h>"
)

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_replace_string("${SOURCE_PATH}/src/internal_utils.hpp"
        [[#include "LIEF/iterators.hpp"]]
        "#include <LIEF/iterators.hpp>\n#include <memory>"
    )
endif()

vcpkg_replace_string("${SOURCE_PATH}/include/LIEF/errors.hpp"
    [[#include <LIEF/third-party/expected.hpp>]]    
    "#include <tl/expected.hpp>"
)

vcpkg_replace_string("${SOURCE_PATH}/include/LIEF/span.hpp"
    [[#include <LIEF/third-party/span.hpp>]]
    "#include <tcb/span.hpp>"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "c-api"          LIEF_C_API             # C API
        "enable-json"    LIEF_ENABLE_JSON       # Enable JSON-related APIs
        "examples"       LIEF_EXAMPLES          # Build LIEF C++ examples
        "extra-warnings" LIEF_EXTRA_WARNINGS    # Enable extra warning from the compiler
        "logging"        LIEF_LOGGING           # Enable logging
        "logging-debug"  LIEF_LOGGING_DEBUG     # Enable debug logging

        "use-ccache"     LIEF_USE_CCACHE        # Use ccache to speed up compilation

        "elf"            LIEF_ELF               # Build LIEF with ELF module
        "pe"             LIEF_PE                # Build LIEF with PE  module
        "macho"          LIEF_MACHO             # Build LIEF with MachO module

        "oat"            LIEF_OAT               # Build LIEF with OAT module
        "dex"            LIEF_DEX               # Build LIEF with DEX module
        "vdex"           LIEF_VDEX              # Build LIEF with VDEX module
        "art"            LIEF_ART               # Build LIEF with ART module
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}

        # Build with external vcpkg dependencies
        -DLIEF_OPT_MBEDTLS_EXTERNAL=ON
        -DLIEF_EXTERNAL_SPDLOG=ON
        -DLIEF_OPT_NLOHMANN_JSON_EXTERNAL=ON
        -DLIEF_OPT_FROZEN_EXTERNAL=ON
        -DLIEF_OPT_EXTERNAL_SPAN=ON
        -DLIEF_OPT_UTFCPP_EXTERNAL=ON
        -DLIEF_OPT_EXTERNAL_EXPECTED=ON
        -DLIEF_DISABLE_FROZEN=OFF
        -DLIEF_DISABLE_EXCEPTIONS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/LIEF")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFConfig.cmake"
    [[include("${LIEF_${lib_type}_export}")]]
    [[include("${CMAKE_CURRENT_LIST_DIR}/LIEFExport-${lib_type}.cmake")]]
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
