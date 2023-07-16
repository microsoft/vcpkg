vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/protobuf
    REF v23.4
    SHA512 b93a4e0339ecbe085796de5b6c61feae35229d40db9019c043090bcaa483a1cce78a99487c5638482c68832fcede5579a0e5ec731221a88359b80db9bb6dc566
    PATCHES
        fix-static-build.patch
        fix-default-proto-file-path.patch
)

string(COMPARE EQUAL "${TARGET_TRIPLET}" "${HOST_TRIPLET}" protobuf_BUILD_PROTOC_BINARIES)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" protobuf_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" protobuf_MSVC_STATIC_RUNTIME)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        zlib protobuf_WITH_ZLIB
)

if(VCPKG_TARGET_IS_UWP)
    set(protobuf_BUILD_LIBPROTOC OFF)
else()
    set(protobuf_BUILD_LIBPROTOC ON)
endif()

if (VCPKG_DOWNLOAD_MODE)
    # download PKGCONFIG in download mode which is used in `vcpkg_fixup_pkgconfig()` at the end of this script.
    # download it here because `vcpkg_cmake_configure()` halts execution in download mode when running configure process.
    vcpkg_find_acquire_program(PKGCONFIG)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dprotobuf_BUILD_SHARED_LIBS=${protobuf_BUILD_SHARED_LIBS}
        -Dprotobuf_MSVC_STATIC_RUNTIME=${protobuf_MSVC_STATIC_RUNTIME}
        -Dprotobuf_BUILD_TESTS=OFF
        -DCMAKE_INSTALL_CMAKEDIR:STRING=share/protobuf
        -Dprotobuf_BUILD_PROTOC_BINARIES=${protobuf_BUILD_PROTOC_BINARIES}
        -Dprotobuf_BUILD_LIBPROTOC=${protobuf_BUILD_LIBPROTOC}
        -Dprotobuf_ABSL_PROVIDER:STRING=package
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME utf8_range CONFIG_PATH lib/cmake/utf8_range)

# It appears that at this point the build hasn't actually finished. There is probably
# a process spawned by the build, therefore we need to wait a bit.

function(protobuf_try_remove_recurse_wait PATH_TO_REMOVE)
    file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    if (EXISTS "${PATH_TO_REMOVE}")
        execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 5)
        file(REMOVE_RECURSE ${PATH_TO_REMOVE})
    endif()
endfunction()

protobuf_try_remove_recurse_wait("${CURRENT_PACKAGES_DIR}/debug/include")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/protobuf/protobuf-targets-release.cmake"
        "\${_IMPORT_PREFIX}/bin/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        "\${_IMPORT_PREFIX}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    )
endif()

protobuf_try_remove_recurse_wait("${CURRENT_PACKAGES_DIR}/debug/share")

if(protobuf_BUILD_PROTOC_BINARIES)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_copy_tools(TOOL_NAMES protoc AUTO_CLEAN)
    else()
        vcpkg_copy_tools(TOOL_NAMES protoc protoc-${VERSION}.0 AUTO_CLEAN)
    endif()
else()
    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/protobuf-config.cmake"
    "if(protobuf_MODULE_COMPATIBLE)"
    "if(ON)"
)
if(NOT protobuf_BUILD_LIBPROTOC)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/protobuf-module.cmake"
        "_protobuf_find_libraries(Protobuf_PROTOC protoc)"
        ""
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    protobuf_try_remove_recurse_wait("${CURRENT_PACKAGES_DIR}/bin")
    protobuf_try_remove_recurse_wait("${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/google/protobuf/stubs/platform_macros.h"
        "\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_"
        "\#ifndef PROTOBUF_USE_DLLS\n\#define PROTOBUF_USE_DLLS\n\#endif // PROTOBUF_USE_DLLS\n\n\#endif  // GOOGLE_PROTOBUF_PLATFORM_MACROS_H_"
    )
endif()

vcpkg_copy_pdbs()
set(packages protobuf protobuf-lite)
foreach(_package IN LISTS packages)
    set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${_package}.pc")
    if(EXISTS "${_file}")
        vcpkg_replace_string(${_file} "-l${_package}" "-l${_package}d")
        vcpkg_replace_string(${_file} "absl_abseil_dll" "abseil_dll")
    endif()
    set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${_package}.pc")
    if(EXISTS "${_file}")
        vcpkg_replace_string(${_file} "absl_abseil_dll" "abseil_dll")
    endif()
endforeach()

vcpkg_fixup_pkgconfig()

if(NOT protobuf_BUILD_PROTOC_BINARIES)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/protobuf-targets-vcpkg-protoc.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/protobuf-targets-vcpkg-protoc.cmake" COPYONLY)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
