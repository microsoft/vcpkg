vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/protobuf
    REF fde7cf7358ec7cd69e8db9be4f1fa6a5c431386a    #v3.13.0
    SHA512 b458410311a0905048c86d70ded263ae0cbb6693fd42cba730d3a95c69ca533cf453eb15c5f8bf8b00003ddc63fe96b3c4242907e2d6b00d5bec5d37b2ae1c5e
    HEAD_REF master
    PATCHES
        fix-uwp.patch
        fix-android-log.patch
        fix-static-build.patch
)

if(CMAKE_HOST_WIN32 AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x64" AND NOT VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    set(protobuf_BUILD_PROTOC_BINARIES OFF)
elseif(CMAKE_HOST_WIN32 AND NOT VCPKG_TARGET_IS_MINGW AND NOT (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP))
    set(protobuf_BUILD_PROTOC_BINARIES OFF)
else()
    set(protobuf_BUILD_PROTOC_BINARIES ON)
endif()

if(NOT protobuf_BUILD_PROTOC_BINARIES AND NOT EXISTS ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/protobuf)
    message(FATAL_ERROR "Cross-targetting protobuf requires the x86-windows protoc to be available. Please install protobuf:x86-windows first.")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_SHARED_LIBS ON)
else()
  set(VCPKG_BUILD_SHARED_LIBS OFF)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
  set(VCPKG_BUILD_STATIC_CRT OFF)
else()
  set(VCPKG_BUILD_STATIC_CRT ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
	zlib	protobuf_WITH_ZLIB
)

if (VCPKG_DOWNLOAD_MODE)
    # download PKGCONFIG in download mode which is used in `vcpkg_fixup_pkgconfig()` at the end of this script.
    # download it here because `vcpkg_configure_cmake()` halts execution in download mode when running configure process.
    vcpkg_find_acquire_program(PKGCONFIG)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake
    PREFER_NINJA
    OPTIONS
        -Dprotobuf_BUILD_SHARED_LIBS=${VCPKG_BUILD_SHARED_LIBS}
        -Dprotobuf_MSVC_STATIC_RUNTIME=${VCPKG_BUILD_STATIC_CRT}
        -Dprotobuf_BUILD_TESTS=OFF
        -DCMAKE_INSTALL_CMAKEDIR:STRING=share/protobuf
        -Dprotobuf_BUILD_PROTOC_BINARIES=${protobuf_BUILD_PROTOC_BINARIES}
         ${FEATURE_OPTIONS}
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
	vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake
		"\${_IMPORT_PREFIX}/bin/protoc${EXECUTABLE_SUFFIX}"
		"\${_IMPORT_PREFIX}/tools/protobuf/protoc${EXECUTABLE_SUFFIX}"
)
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
        vcpkg_copy_tools(TOOL_NAMES protoc)
    else()
        file(COPY ${CURRENT_INSTALLED_DIR}/../x86-windows/tools/${PORT} DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)
    else()
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin/protoc.exe)
        protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin/protoc.exe)
    endif()
else()
    file(GLOB EXECUTABLES ${CURRENT_PACKAGES_DIR}/bin/protoc*)
    foreach(E IN LISTS EXECUTABLES)
        file(INSTALL ${E} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
                PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_WRITE GROUP_EXECUTE WORLD_READ)
    endforeach()
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/debug/bin)
    protobuf_try_remove_recurse_wait(${CURRENT_PACKAGES_DIR}/bin)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
	vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h
		"\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_"
		"\#ifndef PROTOBUF_USE_DLLS\n\#define PROTOBUF_USE_DLLS\n\#endif // PROTOBUF_USE_DLLS\n\n\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_"
)
endif()

vcpkg_copy_pdbs()
set(packages protobuf protobuf-lite)
foreach(_package IN LISTS packages)
    set(_file ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${_package}.pc)
    if(EXISTS "${_file}")
        vcpkg_replace_string(${_file} "-l${_package}" "-l${_package}d")
    endif()
endforeach()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(SYSTEM_LIBRARIES SYSTEM_LIBRARIES pthread)
endif()
vcpkg_fixup_pkgconfig(${SYSTEM_LIBRARIES})

configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake @ONLY)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)