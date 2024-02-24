vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glfw/glfw
    REF ${VERSION}
    SHA512 39ad7a4521267fbebc35d2ff0c389a56236ead5fa4bdff33db113bd302f70f5f2869ff4e6db1979512e1542813292dff5a482e94dfce231750f0746c301ae9ed
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
    wayland         GLFW_BUILD_WAYLAND
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
