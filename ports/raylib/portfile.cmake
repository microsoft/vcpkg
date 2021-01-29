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
    REF e25e380e80a117f2404d65b37700fb620dc1f990 # 3.5.0
    SHA512 67a2cf4f7a4be88e958f8d6c68f270b1500fde8752b32d401fa80026d2d81dbdd9f57ea754f10095858ae0deab93383d675ad3a1b45f2051a4cc1d02db64dc01
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hidpi SUPPORT_HIGH_DPI
        use-audio USE_AUDIO
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_GAMES=OFF
        -DSHARED=${SHARED}
        -DSTATIC=${STATIC}
        -DUSE_EXTERNAL_GLFW=OFF # externl glfw3 causes build errors on Windows
        ${FEATURE_OPTIONS}
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

configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
