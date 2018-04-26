include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/protobuf
    REF v3.6.0.1
    SHA512 63cd799d5d6edbb05a87bc07992271c5bdb9595366d698b4dc5476cc89dc278d1c43186b9e56340958aefea2ce23e15a9c3a550158414add868b56e789ceafe4
    HEAD_REF master
    PATCHES
        # "${CMAKE_CURRENT_LIST_DIR}/001-add-compiler-flag.patch"
        # "${CMAKE_CURRENT_LIST_DIR}/export-ParseGeneratorParameter.patch"
        "${CMAKE_CURRENT_LIST_DIR}/js-embed.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-uwp.patch"
        # "${CMAKE_CURRENT_LIST_DIR}/wire_format_lite_h_fix_error_C4146.patch"
)

# set(PROTOBUF_VERSION 3.6.0.1)
#set(PROTOC_VERSION 3.5.1)

# vcpkg_download_distfile(ARCHIVE_FILE
#     URLS "https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
#     FILENAME "protobuf-cpp-${PROTOBUF_VERSION}.tar.gz"
#     SHA512 195ccb210229e0a1080dcdb0a1d87b2e421ad55f6b036c56db3183bd50a942c75b4cc84e6af8a10ad88022a247781a06f609a145a461dfbb8f04051b7dd714b3
# )
# set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION})

# vcpkg_extract_source_archive(${ARCHIVE_FILE})

# # Add a flag that can be set to disable the protobuf compiler
# vcpkg_apply_patches(
#     SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION}
#     PATCHES
#         "${CMAKE_CURRENT_LIST_DIR}/001-add-compiler-flag.patch"
#         "${CMAKE_CURRENT_LIST_DIR}/export-ParseGeneratorParameter.patch"
#         "${CMAKE_CURRENT_LIST_DIR}/js-embed.patch"
#         "${CMAKE_CURRENT_LIST_DIR}/fix-uwp.patch"
#         "${CMAKE_CURRENT_LIST_DIR}/wire_format_lite_h_fix_error_C4146.patch"
# )

# if(CMAKE_HOST_WIN32)
#     set(TOOL_PATH ${CURRENT_BUILDTREES_DIR}/src/protobuf-${PROTOBUF_VERSION}-win32)
#     vcpkg_download_distfile(TOOL_ARCHIVE_FILE
#         URLS "https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-win32.zip"
#         FILENAME "protoc-${PROTOC_VERSION}-win32.zip"
#         SHA512 27b1b82e92d82c35158362435a29f590961b91f68cda21bffe46e52271340ea4587c4e3177668809af0d053b61e6efa69f0f62156ea11393cd9e6eb4474a3049
#     )

#     vcpkg_extract_source_archive(${TOOL_ARCHIVE_FILE} ${TOOL_PATH})
# endif()

if(CMAKE_HOST_WIN32 AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(protobuf_BUILD_PROTOC_BINARIES OFF)
elseif(CMAKE_HOST_WIN32 AND VCPKG_CMAKE_SYSTEM_NAME)
    set(protobuf_BUILD_PROTOC_BINARIES OFF)
else()
    set(protobuf_BUILD_PROTOC_BINARIES ON)
endif()

if(NOT protobuf_BUILD_PROTOC_BINARIES AND NOT EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/protobuf)
    message(FATAL_ERROR "Cross-targetting protobuf requires the x86-windows protoc to be available. Please install protobuf:x86-windows first.")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(protobuf_BUILD_SHARED_LIBS ON)
else()
    set(protobuf_BUILD_SHARED_LIBS OFF)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
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
        -DCMAKE_INSTALL_CMAKEDIR:STRING=share/protobuf
        -Dprotobuf_BUILD_PROTOC_BINARIES=${protobuf_BUILD_PROTOC_BINARIES}
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
    string(REPLACE "\${_IMPORT_PREFIX}/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/protobuf/protoc${CMAKE_EXECUTABLE_SUFFIX}" RELEASE_MODULE "${RELEASE_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake "${RELEASE_MODULE}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/share/protobuf/protobuf-targets-debug.cmake DEBUG_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
    string(REPLACE "\${_IMPORT_PREFIX}/debug/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/protobuf/protoc${CMAKE_EXECUTABLE_SUFFIX}" DEBUG_MODULE "${DEBUG_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-debug.cmake "${DEBUG_MODULE}")
endif()

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/share)

if(protobuf_BUILD_PROTOC_BINARIES)
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/protoc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/protobuf)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/protobuf)
else()
    file(COPY ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/protobuf DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
endif()

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
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/protoc DESTINATION ${CURRENT_PACKAGES_DIR}/tools/protobuf
            PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_WRITE GROUP_EXECUTE WORLD_READ)
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h _contents)
    string(REPLACE "\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" "\#define PROTOBUF_USE_DLLS\n\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h "${_contents}")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/protobuf RENAME copyright)
vcpkg_copy_pdbs()
