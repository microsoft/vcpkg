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

if(VCPKG_TARGET_IS_EMSCRIPTEN)
    set(ADDITIONAL_OPTIONS "-DPLATFORM=Web")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raysan5/raylib
    REF "${VERSION}"
    SHA512 5956bc1646b99baac6eb1652c4d72e96af874337158672155ba144f131de8a4fd19291a58335a92fcaaa2fc818682f93ff4230af0f815efb8b49f7d2a162e9b0
    HEAD_REF master
    PATCHES
        ${patches}
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
        ${ADDITIONAL_OPTIONS}
    OPTIONS_DEBUG
        -DENABLE_ASAN=${DEBUG_ENABLE_SANITIZERS}
        -DENABLE_UBSAN=${DEBUG_ENABLE_SANITIZERS}
        -DENABLE_MSAN=OFF
    OPTIONS_RELEASE
        -DENABLE_ASAN=OFF
        -DENABLE_UBSAN=OFF
        -DENABLE_MSAN=OFF
    MAYBE_UNUSED_VARIABLES
        SHARED
        STATIC
        SUPPORT_HIGH_DPI
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
