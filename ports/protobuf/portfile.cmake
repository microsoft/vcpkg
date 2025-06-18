vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protocolbuffers/protobuf
    REF "v${VERSION}"
    SHA512 32a9ae3de113b8c94e2aed21ad8f58e5ed4419a6d4078e51f614f0fabbf3bfe6c4affc62c2c1326e030a54df0fdcc47bb715b45022191a363f17680ec651b68e
    HEAD_REF master
    PATCHES
        fix-static-build.patch
        fix-default-proto-file-path.patch
        fix-utf8-range.patch
        fix-install-dirs.patch
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

# Delete language backends we aren't targeting to reduce false positives in automated dependency
# detectors like Dependabot.
file(REMOVE_RECURSE
    "${SOURCE_PATH}/csharp"
    "${SOURCE_PATH}/java"
    "${SOURCE_PATH}/lua"
    "${SOURCE_PATH}/objectivec"
    "${SOURCE_PATH}/php"
    "${SOURCE_PATH}/python"
    "${SOURCE_PATH}/ruby"
    "${SOURCE_PATH}/rust"
    "${SOURCE_PATH}/go"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dprotobuf_BUILD_SHARED_LIBS=${protobuf_BUILD_SHARED_LIBS}
        -Dprotobuf_MSVC_STATIC_RUNTIME=${protobuf_MSVC_STATIC_RUNTIME}
        -Dprotobuf_BUILD_TESTS=OFF
        -DCMAKE_INSTALL_CMAKEDIR:STRING=share/protobuf
        -Dprotobuf_BUILD_PROTOC_BINARIES=${protobuf_BUILD_PROTOC_BINARIES}
        -Dprotobuf_BUILD_LIBPROTOC=${protobuf_BUILD_LIBPROTOC}
        -Dprotobuf_ABSL_PROVIDER=package
        -Dprotobuf_BUILD_LIBUPB=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if(protobuf_BUILD_PROTOC_BINARIES)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_copy_tools(TOOL_NAMES protoc AUTO_CLEAN)
    else()
        string(REPLACE "." ";" VERSION_LIST ${VERSION})
        list(GET VERSION_LIST 1 VERSION_MINOR)
        list(GET VERSION_LIST 2 VERSION_PATCH)
        vcpkg_copy_tools(TOOL_NAMES protoc protoc-${VERSION_MINOR}.${VERSION_PATCH}.0 AUTO_CLEAN)
    endif()
else()
    file(COPY "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}" DESTINATION "${CURRENT_PACKAGES_DIR}/tools")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/protobuf-config.cmake"
    "if(protobuf_MODULE_COMPATIBLE)"
    "if(protobuf_MODULE_COMPATIBLE OR CMAKE_FIND_PACKAGE_NAME STREQUAL \"Protobuf\")"
)
if(NOT protobuf_BUILD_LIBPROTOC)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/protobuf-module.cmake"
        "_protobuf_find_libraries(Protobuf_PROTOC protoc)"
        ""
    )
endif()

vcpkg_cmake_config_fixup()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/google/protobuf/port_def.inc"
        "\#ifdef PROTOBUF_PORT_"
        "\#ifndef PROTOBUF_USE_DLLS\n\#define PROTOBUF_USE_DLLS\n\#endif // PROTOBUF_USE_DLLS\n\n\#ifdef PROTOBUF_PORT_"
    )
endif()

vcpkg_copy_pdbs()

function(replace_package_string package)
    set(debug_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/${package}.pc")
    set(release_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/${package}.pc")

    if(EXISTS "${release_file}")
        vcpkg_replace_string("${release_file}" "absl_abseil_dll" "abseil_dll" IGNORE_UNCHANGED)
        if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
            vcpkg_replace_string("${release_file}" "-l${package}" "-llib${package}" IGNORE_UNCHANGED)
        endif()
    endif()

    if(EXISTS "${debug_file}")
        vcpkg_replace_string("${debug_file}" "absl_abseil_dll" "abseil_dll" IGNORE_UNCHANGED)
        if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
            vcpkg_replace_string("${debug_file}" "-l${package}" "-llib${package}d" IGNORE_UNCHANGED)
        else()
            vcpkg_replace_string("${debug_file}" "-l${package}" "-l${package}d" IGNORE_UNCHANGED)
        endif()
    endif()
endfunction()

set(packages protobuf protobuf-lite)
foreach(package IN LISTS packages)
    replace_package_string("${package}")
endforeach()


vcpkg_fixup_pkgconfig()

if(NOT protobuf_BUILD_PROTOC_BINARIES)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/protobuf-targets-vcpkg-protoc.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/protobuf-targets-vcpkg-protoc.cmake" COPYONLY)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
