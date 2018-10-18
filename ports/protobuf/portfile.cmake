include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/protobuf
    REF v3.6.1
    SHA512 1bc175d24b49de1b1e41eaf39598194e583afffb924c86c8d2e569d935af21874be76b2cbd4d9655a1d38bac3d4cd811de88bc2c72d81bad79115e69e5b0d839
    HEAD_REF master
    PATCHES
        fix-uwp.patch
        disable-lite.patch
)

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

if(CMAKE_HOST_WIN32)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake RELEASE_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}/bin/protoc${EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/protobuf/protoc${EXECUTABLE_SUFFIX}" RELEASE_MODULE "${RELEASE_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake "${RELEASE_MODULE}")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_PACKAGES_DIR}/debug/share/protobuf/protobuf-targets-debug.cmake DEBUG_MODULE)
    string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
    string(REPLACE "\${_IMPORT_PREFIX}/debug/bin/protoc${EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/protobuf/protoc${EXECUTABLE_SUFFIX}" DEBUG_MODULE "${DEBUG_MODULE}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-debug.cmake "${DEBUG_MODULE}")
endif()

protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/share)

if(CMAKE_HOST_WIN32)
    if(protobuf_BUILD_PROTOC_BINARIES)
        file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/protoc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/protobuf)
        vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/protobuf)
    else()
        file(COPY ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/protobuf DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
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

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/libprotobuf-lite.lib)
    message(FATAL_ERROR "Expected to not build the lite runtime because it contains some of the same symbols as the full runtime.")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(READ ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h _contents)
    string(REPLACE "\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" "\#define PROTOBUF_USE_DLLS\n\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_" _contents "${_contents}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h "${_contents}")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/protobuf RENAME copyright)
vcpkg_copy_pdbs()
