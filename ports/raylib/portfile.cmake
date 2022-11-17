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

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_LINUX)
    set(patches fix-linkGlfw.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raysan5/raylib
    REF bf2ad9df5fdcaa385b2a7f66fd85632eeebbadaa #v4.2.0
    SHA512 f6b1738d96fef89059062f570f67aaa8b143ccfbee78abfe5fbb25083371a4c432f3d1d0d357e4b475b4b72a6db7823c2341b70ac947759603b033c2b0acec47
    HEAD_REF master
    PATCHES ${patches}
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
