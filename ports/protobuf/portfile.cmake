include(vcpkg_common_functions)

set(PROTOBUF_VERSION 3.3.0)

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
    FILENAME "protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
    SHA512 ef01300bdda4a1a33a6056aea1d55e9d66ab1ca644aa2d9d5633cfc0bccfe4c24fdfa1015889b2c1c568e89ad053c701de1aca45196a6439130b7bb8f461595f
)
vcpkg_download_distfile(TOOL_ARCHIVE_FILE
    URLS "https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-win32.zip"
    FILENAME "protoc-${PROTOBUF_VERSION}-win32.zip"
    SHA512 9b4902b3187fb978a8153aaf050314a3ca9ca161b0712a3672ccdfabb7f5a57035e71c2dfde9a0b99f9417e159dcbdedaf9a2b1917d712dc3d9d554bba0d4ee8
)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION})
set(TOOL_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION}-win32)

vcpkg_extract_source_archive(${ARCHIVE_FILE})

# Patch to fix the missing export of fixed_address_empty_string,
# see https://github.com/google/protobuf/pull/3216
# Add a flag that can be set to disable the protobuf compiler
vcpkg_apply_patches(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-fix-missing-export.patch"
            "${CMAKE_CURRENT_LIST_DIR}/001-add-compiler-flag.patch"
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    OPTIONS
        -Dprotobuf_BUILD_SHARED_LIBS=${protobuf_BUILD_SHARED_LIBS}
        -Dprotobuf_MSVC_STATIC_RUNTIME=${protobuf_MSVC_STATIC_RUNTIME}
        -Dprotobuf_WITH_ZLIB=ON
        -Dprotobuf_BUILD_TESTS=OFF
        -Dprotobuf_BUILD_COMPILER=${protobuf_BUILD_COMPILER}
        -DCMAKE_INSTALL_CMAKEDIR=share/protobuf
)

# Using 64-bit toolset to avoid occassional Linker Out-of-Memory issues.
vcpkg_install_cmake(MSVC_64_TOOLSET)

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

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/protobuf RENAME copyright)
file(INSTALL ${TOOL_PATH}/bin/protoc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
vcpkg_copy_pdbs()
