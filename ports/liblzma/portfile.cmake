vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xz-mirror/xz
    REF v5.2.5
    SHA512 686f01cfe33e2194766a856c48668c661b25eee194a443524f87ce3f866e0eb54914075b4e00185921516c5211db8cd5d2658f4b91f4a3580508656f776f468e
    HEAD_REF master
    PATCHES
        enable-uwp-builds.patch
        fix_config_include.patch
        win_output_name.patch # Fix output name on Windows. Autotool build does not generate lib prefixed libraries on windows. 
        add_support_ios.patch # add install bundle info for support ios 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_DEBUG_POSTFIX=d" # This was in the old vcpkg CMakeLists.txt and I don't intend to fix it all over vcpkg 
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

set(exec_prefix "\${prefix}")
set(libdir "\${prefix}/lib")
set(includedir "\${prefix}/include")
set(PACKAGE_URL https://tukaani.org/xz/)
set(PACKAGE_VERSION 5.2.5)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(PTHREAD_CFLAGS -pthread)
endif()
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  set(prefix "${CURRENT_INSTALLED_DIR}")
  configure_file("${SOURCE_PATH}/src/liblzma/liblzma.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/liblzma.pc" @ONLY)
endif()
if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  set(prefix "${CURRENT_INSTALLED_DIR}/debug")
  configure_file("${SOURCE_PATH}/src/liblzma/liblzma.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/liblzma.pc" @ONLY)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/liblzma.pc" "-llzma" "-llzmad")
endif()
vcpkg_fixup_pkgconfig()


vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/liblzma)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/liblzma/liblzma-config.cmake" "include(\"\${CMAKE_CURRENT_LIST_DIR}/liblzmaConfig.cmake\")")
file(APPEND "${CURRENT_PACKAGES_DIR}/share/liblzma/liblzmaConfig.cmake"
"
include(\${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)
find_path(LibLZMA_INCLUDE_DIR
    NAMES lzma.h
    PATH_SUFFIXES lzma
)
if(NOT LibLZMA_LIBRARY)
    find_library(LibLZMA_LIBRARY_RELEASE NAMES lzma LZMA LibLZMA liblzma PATHS \${_IMPORT_PREFIX}/lib/)
    find_library(LibLZMA_LIBRARY_DEBUG NAMES lzmad LZMAd LibLZMAd lzma LZMA LibLZMA liblzma PATHS \${_IMPORT_PREFIX}/debug/lib/)
    select_library_configurations(LibLZMA)
endif()
set(LibLZMA_INCLUDE_DIRS \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LibLZMA_LIBRARIES \${LibLZMA_LIBRARY} CACHE STRING \"\")
set(LZMA_INCLUDE_DIR \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LZMA_LIBRARY \${LibLZMA_LIBRARY} CACHE STRING \"\")
set(LZMA_INCLUDE_DIRS \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LZMA_LIBRARIES \${LibLZMA_LIBRARY} CACHE STRING \"\")
set(LIBLZMA_INCLUDE_DIRS \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LIBLZMA_LIBRARIES \${LibLZMA_LIBRARY} CACHE STRING \"\")
set(LIBLZMA_INCLUDE_DIR \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LIBLZMA_LIBRARY \${LibLZMA_LIBRARY} CACHE STRING \"\")

if(LIBLZMA_INCLUDE_DIR AND EXISTS \"\${LIBLZMA_INCLUDE_DIR}/lzma/version.h\")
    file(STRINGS \"\${LIBLZMA_INCLUDE_DIR}/lzma/version.h\" LIBLZMA_HEADER_CONTENTS REGEX \"#define LZMA_VERSION_[A-Z]+ [0-9]+\")

    string(REGEX REPLACE \".*#define LZMA_VERSION_MAJOR ([0-9]+).*\" \"\\\\1\" LIBLZMA_VERSION_MAJOR \"\${LIBLZMA_HEADER_CONTENTS}\")
    string(REGEX REPLACE \".*#define LZMA_VERSION_MINOR ([0-9]+).*\" \"\\\\1\" LIBLZMA_VERSION_MINOR \"\${LIBLZMA_HEADER_CONTENTS}\")
    string(REGEX REPLACE \".*#define LZMA_VERSION_PATCH ([0-9]+).*\" \"\\\\1\" LIBLZMA_VERSION_PATCH \"\${LIBLZMA_HEADER_CONTENTS}\")

    set(LIBLZMA_VERSION_STRING \"\${LIBLZMA_VERSION_MAJOR}.\${LIBLZMA_VERSION_MINOR}.\${LIBLZMA_VERSION_PATCH}\")
    unset(LIBLZMA_HEADER_CONTENTS)
endif()

## We're using new code known now as XZ, even library still been called LZMA
## it can be found in http://tukaani.org/xz/
## Avoid using old codebase
#if (LIBLZMA_LIBRARY)
#   include(\${CMAKE_ROOT}/Modules/CheckLibraryExists.cmake)
#   CHECK_LIBRARY_EXISTS(\${LibLZMA_LIBRARY_RELEASE} lzma_auto_decoder \"\" LIBLZMA_HAS_AUTO_DECODER)
#   CHECK_LIBRARY_EXISTS(\${LibLZMA_LIBRARY_RELEASE} lzma_easy_encoder \"\" LIBLZMA_HAS_EASY_ENCODER)
#   CHECK_LIBRARY_EXISTS(\${LibLZMA_LIBRARY_RELEASE} lzma_lzma_preset \"\" LIBLZMA_HAS_LZMA_PRESET)
#endif ()

set(LibLZMA_FOUND TRUE CACHE BOOL \"\")
set(LZMA_FOUND TRUE CACHE BOOL \"\")
set(LIBLZMA_FOUND TRUE CACHE BOOL \"\")
")

file(READ ${CURRENT_PACKAGES_DIR}/include/lzma.h _contents)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined(LZMA_API_STATIC)" "1" _contents "${_contents}")
else()
    string(REPLACE "defined(LZMA_API_STATIC)" "0" _contents "${_contents}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/lzma.h "${_contents}")

if (VCPKG_BUILD_TYPE STREQUAL debug)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/include")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/lzma.h"
        "if !defined(LZMA_API_STATIC)"
        "if 0"
    )
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(TOOLS xz xzdec)
foreach(_tool IN LISTS TOOLS)
    if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        list(REMOVE_ITEM TOOLS ${_tool})
    endif()
endforeach()
if(TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${TOOLS} AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")