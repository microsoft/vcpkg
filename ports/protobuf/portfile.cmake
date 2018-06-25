include(vcpkg_common_functions)

set(PROTOBUF_VERSION 3.6.0)
set(PROTOC_VERSION 3.6.0)

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
    FILENAME "protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
    SHA512 469a85026ca45dc43ccd01221d098905a244e92ca79a6681fae528a3a539184475e14fff9898a0eb82654782fd60c5e4650896b5ce7c7ab3f1baa879251c94b3
)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION})

vcpkg_extract_source_archive(${ARCHIVE_FILE})

# Add a flag that can be set to disable the protobuf compiler
vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/001-add-compiler-flag.patch"
        "${CMAKE_CURRENT_LIST_DIR}/export-ParseGeneratorParameter.patch"
        "${CMAKE_CURRENT_LIST_DIR}/js-embed.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-uwp.patch"
        "${CMAKE_CURRENT_LIST_DIR}/wire_format_lite_h_fix_error_C4146.patch"
)

if(CMAKE_HOST_WIN32)
    set(TOOL_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION}-win32)
    vcpkg_download_distfile(TOOL_ARCHIVE_FILE
        URLS "https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-win32.zip"
        FILENAME "protoc-${PROTOC_VERSION}-win32.zip"
        SHA512 18a134a50801270739975e0d4d1241c04ac36c8bf90f893bc0aed82f7843784ffac662fd43bad627e4ab940dbbee148a7ad98d3a829f0e52b5bdae7214eacc0e
    )

    vcpkg_extract_source_archive(${TOOL_ARCHIVE_FILE} ${TOOL_PATH})
endif()


# Disable the protobuf compiler when targeting UWP
if(CMAKE_HOST_WIN32 AND VCPKG_CMAKE_SYSTEM_NAME)
  set(protobuf_BUILD_COMPILER OFF)
else()
  set(protobuf_BUILD_COMPILER ON)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(protobuf_BUILD_SHARED_LIBS ON)
else()
    set(protobuf_BUILD_SHARED_LIBS OFF)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL static)
    set(protobuf_MSVC_STATIC_RUNTIME ON)
else()
    set(protobuf_MSVC_STATIC_RUNTIME OFF)
endif()

if("zlib" IN_LIST FEATURES)
    set(protobuf_WITH_ZLIB ON)
else()
    set(protobuf_WITH_ZLIB OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    PREFER_NINJA
    OPTIONS
        -Dprotobuf_BUILD_SHARED_LIBS=${protobuf_BUILD_SHARED_LIBS}
        -Dprotobuf_MSVC_STATIC_RUNTIME=${protobuf_MSVC_STATIC_RUNTIME}
        -Dprotobuf_WITH_ZLIB=${protobuf_WITH_ZLIB}
        -Dprotobuf_BUILD_TESTS=OFF
        -Dprotobuf_BUILD_COMPILER=${protobuf_BUILD_COMPILER}
        -DCMAKE_INSTALL_CMAKEDIR=share/protobuf
)

vcpkg_install_cmake()

# It appears that at this point the build hasn't actually finished. There is probably
# a process spawned by the build, therefore we need to wait a bit.

function(protobuf_try_remove_recurse_wait PATH_TO_REMOVE)
    file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    if (EXISTS "${PATH_TO_REMOVE}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 5)
        file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    endif()
endfunction()

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/include)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake RELEASE_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/protoc${CMAKE_EXECUTABLE_SUFFIX}" RELEASE_MODULE "${RELEASE_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake "${RELEASE_MODULE}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/share/protobuf/protobuf-targets-debug.cmake DEBUG_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
    string(REPLACE "\${_IMPORT_PREFIX}/debug/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/protoc${CMAKE_EXECUTABLE_SUFFIX}" DEBUG_MODULE "${DEBUG_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-debug.cmake "${DEBUG_MODULE}")
endif()

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/share)

if(CMAKE_HOST_WIN32)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)
    else()
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin/protoc.exe)
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin/protoc.exe)
    endif()
else()
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/protoc DESTINATION ${CURRENT_PACKAGES_DIR}/tools
            PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_WRITE GROUP_EXECUTE WORLD_READ)
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h _contents)
    string(REPLACE "\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" "\#define PROTOBUF_USE_DLLS\n\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h "${_contents}")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/protobuf RENAME copyright)
if(CMAKE_HOST_WIN32)
    file(INSTALL ${TOOL_PATH}/bin/protoc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
endif()
vcpkg_copy_pdbs()
