set(MPG123_VERSION 1.27.0)
set(MPG123_HASH f1323a814de65c0d8f62d9b23f706b2b33bbf36ac8ffb5b5fecd798520de125b8a1078299c9270bac766cdb49abcd15d5dd315edd15be2a9ececd0e8be061b7f)

#architecture detection
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
   set(MPG123_ARCH Win32)
   set(MPG123_CONFIGURATION _x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
   set(MPG123_ARCH x64)
   set(MPG123_CONFIGURATION _x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
   set(MPG123_ARCH ARM)
   set(MPG123_CONFIGURATION _Generic)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
   set(MPG123_ARCH ARM64)
   set(MPG123_CONFIGURATION _Generic)
else()
   message(FATAL_ERROR "unsupported architecture")
endif()

#linking
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(MPG123_CONFIGURATION_SUFFIX _Dll)
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF ${MPG123_VERSION}
    FILENAME "mpg123-${MPG123_VERSION}.tar.bz2"
    SHA512 ${MPG123_HASH}
)

include(${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake)
yasm_tool_helper(APPEND_TO_PATH)

macro(read_api_version)
    file(READ "${SOURCE_PATH}/configure.ac" configure_ac)
    string(REGEX MATCH "API_VERSION=([0-9]+)" result ${configure_ac})
    set(API_VERSION ${CMAKE_MATCH_1})
endmacro()

if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}/ports/cmake
        OPTIONS -DUSE_MODULES=OFF
    )
    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
    vcpkg_fixup_pkgconfig()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

elseif(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_LINUX)
    set(MPG123_OPTIONS
        --disable-dependency-tracking
    )

    # Find cross-compiler prefix
    if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    endif()
    if(CMAKE_C_COMPILER)
        vcpkg_execute_required_process(
            COMMAND ${CMAKE_C_COMPILER} -dumpmachine
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
            LOGNAME dumpmachine-${TARGET_TRIPLET}
        )
        file(READ ${CURRENT_BUILDTREES_DIR}/dumpmachine-${TARGET_TRIPLET}-out.log MPG123_HOST)
        string(REPLACE "\n" "" MPG123_HOST "${MPG123_HOST}")
        message(STATUS "Cross-compiling with ${CMAKE_C_COMPILER}")
        message(STATUS "Detected autoconf triplet --host=${MPG123_HOST}")
        set(MPG123_OPTIONS
            --host=${MPG123_HOST}
            ${MPG123_OPTIONS}
        )
    endif()

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS ${MPG123_OPTIONS}
    )
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

message(STATUS "Installing done")
