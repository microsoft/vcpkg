if(TARGET_TRIPLET MATCHES "^arm" OR TARGET_TRIPLET MATCHES "uwp$")
    message(FATAL_ERROR "raylib doesn't support ARM or UWP.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raysan5/raylib
    REF f1cbdd6b3af5dc51cef306cbbc4619c7b6ed548a
    SHA512 ed228087dab1a3e7e6dd576b46dbd9139e8eb71a0f996de0c0a5686d5d1074fe77eeb7a4b8d6e78dcd556a70a2475f33526566a519109a09a86320a965af37a6
    HEAD_REF master
    PATCHES
        raylib-config.patch
        shared-lib.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC)

if("non-audio" IN_LIST FEATURES)
    set(USE_AUDIO OFF)
else()
    set(USE_AUDIO ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GAMES=OFF
        -DSHARED=${SHARED}
        -DSTATIC=${STATIC}
        -DUSE_AUDIO=${USE_AUDIO}
        -DUSE_EXTERNAL_GLFW=OFF # externl glfw3 causes build errors on Windows
    OPTIONS_DEBUG
        -DENABLE_ASAN=ON
        -DENABLE_UBSAN=ON
        -DENABLE_MSAN=ON
    OPTIONS_RELEASE
        -DENABLE_ASAN=OFF
        -DENABLE_UBSAN=OFF
        -DENABLE_MSAN=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/raylib.h
        "defined(USE_LIBTYPE_SHARED)"
        "1 // defined(USE_LIBTYPE_SHARED)"
    )
endif()

# Install usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
#vcpkg_test_cmake(PACKAGE_NAME ${PORT})
