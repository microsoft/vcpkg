vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glfw/glfw
    REF ${VERSION}
    SHA512 9fcccd650990fa88fcb6383afa90bc6c2eca7f4a4a3d4fc58fa5bd6b7995c32989bb29d2753f438984043b294244b82ba9f094426e12f3d4da4547e73bb62e3f
    HEAD_REF master
)

if(VCPKG_TARGET_IS_LINUX)
    message(
"GLFW3 currently requires the following libraries from the system package manager:
    xinerama
    xcursor
    xorg
    libglu1-mesa
    pkg-config

These can be installed on Ubuntu systems via sudo apt install libxinerama-dev libxcursor-dev xorg-dev libglu1-mesa-dev pkg-config

Alternatively, when targeting the Wayland display server, use the packages listed in the GLFW documentation here:

https://www.glfw.org/docs/3.3/compile.html#compile_deps_wayland")
else(VCPKG_TARGET_IS_OSX)
    message(
"GLFW3 currently requires the following libraries from the system package manager:
    xinerama
    xcursor
    xorg
    libglu1-mesa
    pkg-config

These can be installed via brew install libxinerama-dev libxcursor-dev xorg-dev libglu1-mesa-dev pkg-config")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    wayland         GLFW_USE_WAYLAND
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGLFW_BUILD_EXAMPLES=OFF
        -DGLFW_BUILD_TESTS=OFF
        -DGLFW_BUILD_DOCS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/glfw3)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
