vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lief-project/LIEF
    REF 0d087c03936977cb7019d7ca52f761a347b80778
    SHA512 b1c59a504cef4a300e6e5e788b87252ab4ff5f2c373170fcb4b91aaf4ac122733ab677684fa2e1a7ffcaacf9fc9ae061157aec4ff821e1f5306bdff1dcb7c630
)

file(REMOVE_RECURSE "${SOURCE_PATH}/third-party")

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "target_link_libraries(LIB_LIEF PRIVATE lief_spdlog)"
    "find_package(fmt CONFIG REQUIRED)\nfind_package(spdlog CONFIG REQUIRED)\ntarget_link_libraries(LIB_LIEF PRIVATE fmt::fmt spdlog::spdlog)"
)

vcpkg_replace_string("${SOURCE_PATH}/cmake/LIEFConfig.cmake.in"
    [[if("${lib_type}" STREQUAL "static")]]
    [[if(1)]]
)

vcpkg_replace_string("${SOURCE_PATH}/cmake/LIEFConfig.cmake.in"
    "include(CMakeFindDependencyMacro)"
    "include(CMakeFindDependencyMacro)\nfind_dependency(tl-expected)\nfind_dependency(fmt)"
)

vcpkg_replace_string("${SOURCE_PATH}/cmake/LIEFConfig.cmake.in"
    "if(DEFINED LIEF_INCLUDE_DIR)"
    "check_required_components(lief)\nif(DEFINED LIEF_INCLUDE_DIR)"
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "TARGETS LIB_LIEF lief_spdlog"
    "TARGETS LIB_LIEF"
)

vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}"
    "ARCHIVE DESTINATION lib"
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

        # Sanitizer
        "asan"           LIEF_ASAN               # Enable Address sanitizer
        "lsan"           LIEF_LSAN               # Enable Leak sanitizer
        "tsan"           LIEF_TSAN               # Enable Thread sanitizer
        "usan"           LIEF_USAN               # Enable undefined sanitizer

        # Fuzzer
        "fuzzing"        LIEF_FUZZING            # Fuzz LIEF
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_SHARED_LIBS=ON
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/lib/cmake/LIEF/LIEFExport-static.cmake"
        "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/LIEF/LIEFExport-static.cmake"
    )

    file(MAKE_DIRECTORY
        "${CURRENT_PACKAGES_DIR}/debug/bin" 
        "${CURRENT_PACKAGES_DIR}/bin"
    )

    file(GLOB all_files_in_lib "${CURRENT_PACKAGES_DIR}/lib/*")
    foreach(item IN LISTS all_files_in_lib)
        if(NOT IS_DIRECTORY "${item}")
            get_filename_component(filename "${item}" NAME)
            file(RENAME "${item}" "${CURRENT_PACKAGES_DIR}/bin/${filename}")
        endif()
    endforeach()

    file(GLOB all_files_in_debug_lib "${CURRENT_PACKAGES_DIR}/debug/lib/*")
    foreach(item IN LISTS all_files_in_debug_lib)
        if(NOT IS_DIRECTORY "${item}")
            get_filename_component(filename "${item}" NAME)
            file(RENAME "${item}" "${CURRENT_PACKAGES_DIR}/debug/bin/${filename}")
        endif()
    endforeach()

    file(GLOB liblib_files "${CURRENT_PACKAGES_DIR}/liblib/*")
    foreach(file_path IN LISTS liblib_files)
        get_filename_component(filename "${file_path}" NAME)
        file(RENAME "${file_path}" "${CURRENT_PACKAGES_DIR}/lib/${filename}")
    endforeach()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/liblib")

    file(GLOB liblib_files "${CURRENT_PACKAGES_DIR}/debug/liblib/*")
    foreach(file_path IN LISTS liblib_files)
        get_filename_component(filename "${file_path}" NAME)
        file(RENAME "${file_path}" "${CURRENT_PACKAGES_DIR}/debug/lib/${filename}")
    endforeach()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/liblib")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/LIEF")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFExport-shared-release.cmake"
        [[IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/liblib]]
        [[IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib]]
    )

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFExport-shared-release.cmake"
        [[IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib]]
        [[IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin]]
    )

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFExport-shared-release.cmake"
        [[APPEND _cmake_import_check_files_for_LIEF::LIEF "${_IMPORT_PREFIX}/liblib]]
        [[APPEND _cmake_import_check_files_for_LIEF::LIEF "${_IMPORT_PREFIX}/lib]]
    )

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFExport-shared-release.cmake"
        [[" "${_IMPORT_PREFIX}/lib]]
        [[" "${_IMPORT_PREFIX}/bin]]
    )

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFExport-shared-debug.cmake"
        [[IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/liblib]]
        [[IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/debug/lib]]
    )

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFExport-shared-debug.cmake"
        [[IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/lib]]
        [[IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/debug/bin]]
    )

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFExport-shared-debug.cmake"
        [[APPEND _cmake_import_check_files_for_LIEF::LIEF "${_IMPORT_PREFIX}/debug/liblib]]
        [[APPEND _cmake_import_check_files_for_LIEF::LIEF "${_IMPORT_PREFIX}/debug/lib]]
    )

    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFExport-shared-debug.cmake"
        [[" "${_IMPORT_PREFIX}/debug/lib]]
        [[" "${_IMPORT_PREFIX}/debug/bin]]
    )

endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/lief/LIEFConfig.cmake"
    [[include("${LIEF_${lib_type}_export}")]]
    [[include("${CMAKE_CURRENT_LIST_DIR}/LIEFExport-${lib_type}.cmake")]]
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
