# https://github.com/raysan5/raylib/issues/388
vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_LINUX)
    message(
    "raylib currently requires the following libraries from the system package manager:
    libgl1-mesa-dev
    libx11-dev
    libxcursor-dev
    libxinerama-dev
    libxrandr-dev
These can be installed on Ubuntu systems via sudo apt install libgl1-mesa-dev libx11-dev libxcursor-dev libxinerama-dev libxrandr-dev"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raysan5/raylib
    REF 6f3c99a295533e41de3049db5e683d15fd5c6e1a # 2.6.0
    SHA512 358ebcffb7e11f319f82ecf791480eb23c40a53b764cad1d2109064bb06575c7af0325bf06ec86bbb2c43b70b12f52b5b6d1318d8857e07ff8e965a1dadbd8e2
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
    non-audio USE_AUDIO
)

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
        -DENABLE_MSAN=OFF
    OPTIONS_RELEASE
        -DENABLE_ASAN=OFF
        -DENABLE_UBSAN=OFF
        -DENABLE_MSAN=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake
    @ONLY
)

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
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)