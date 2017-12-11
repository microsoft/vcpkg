include(vcpkg_common_functions)

set(PROTOBUF_VERSION 3.5.0)
set(PROTOC_VERSION 3.5.0)

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
    FILENAME "protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
    SHA512 b1d3f3617898e3f73630ea7a43416a60b970291b4f93952b8d4f68ee5cd401f752d76cd1f6a65a87186b415208142401e01ffebb2ec52534e1db31abcc0d052e
)
vcpkg_download_distfile(TOOL_ARCHIVE_FILE
    URLS "https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-win32.zip"
    FILENAME "protoc-${PROTOC_VERSION}-win32.zip"
    SHA512 d332045346883ac1ca76a77cc9d6303b1c83147f49e7525c531d390b1ac57be1c765e01dc53eeb38a0d9fa3e30cab420f6a6f52dbb0c4d0a84a421de955007a4
)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION})
set(TOOL_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION}-win32)

vcpkg_extract_source_archive(${ARCHIVE_FILE})

# Add a flag that can be set to disable the protobuf compiler
vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/001-add-compiler-flag.patch"
        "${CMAKE_CURRENT_LIST_DIR}/export-ParseGeneratorParameter.patch"
)


vcpkg_extract_source_archive(${TOOL_ARCHIVE_FILE} ${TOOL_PATH})

# Disable the protobuf compiler when targeting UWP
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
  set(protobuf_BUILD_COMPILER OFF)
else()
  set(protobuf_BUILD_COMPILER ON)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
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

file(READ ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake RELEASE_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}/bin/protoc.exe" "\${_IMPORT_PREFIX}/tools/protoc.exe" RELEASE_MODULE "${RELEASE_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake "${RELEASE_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/debug/share/protobuf/protobuf-targets-debug.cmake DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
string(REPLACE "\${_IMPORT_PREFIX}/debug/bin/protoc.exe" "\${_IMPORT_PREFIX}/tools/protoc.exe" DEBUG_MODULE "${DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-debug.cmake "${DEBUG_MODULE}")

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/share)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin/protoc.exe)
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin/protoc.exe)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h _contents)
    string(REPLACE "\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" "\#define PROTOBUF_USE_DLLS\n\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h "${_contents}")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/protobuf RENAME copyright)
file(INSTALL ${TOOL_PATH}/bin/protoc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
vcpkg_copy_pdbs()
