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
    REF 1e436be51d4f8853c3494a0753eabe7628ac6d90 #2022-02-08
    SHA512 9282fd52475ca56dbad02a1082c4f4bcc9eea51b5b126585217ca44cca22b042d083d792fc1d1550091bf72b77243cd46303724bc340ba1deb14a04860d9a143
    HEAD_REF master
    PATCHES
        fix-header-miss.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hidpi SUPPORT_HIGH_DPI
        use-audio USE_AUDIO
)

if(VCPKG_TARGET_IS_MINGW)
    set(DEBUG_ENABLE_SANITIZERS OFF)
else()
    set(DEBUG_ENABLE_SANITIZERS ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DSHARED=${SHARED}
        -DSTATIC=${STATIC}
        -DUSE_EXTERNAL_GLFW=OFF # externl glfw3 causes build errors on Windows
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DENABLE_ASAN=${DEBUG_ENABLE_SANITIZERS}
        -DENABLE_UBSAN=${DEBUG_ENABLE_SANITIZERS}
        -DENABLE_MSAN=OFF
    OPTIONS_RELEASE
        -DENABLE_ASAN=OFF
        -DENABLE_UBSAN=OFF
        -DENABLE_MSAN=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/raylib.h
        "defined(USE_LIBTYPE_SHARED)"
        "1 // defined(USE_LIBTYPE_SHARED)"
    )
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
