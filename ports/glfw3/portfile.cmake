vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glfw/glfw
    REF ${VERSION}
    SHA512 39ad7a4521267fbebc35d2ff0c389a56236ead5fa4bdff33db113bd302f70f5f2869ff4e6db1979512e1542813292dff5a482e94dfce231750f0746c301ae9ed
    HEAD_REF master
)

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    message("${PORT} currently requires the following libraries from the system package manager:
    X11
    XRandR
    Xinerama
    Xcursor
    XInput
    pkg-config
On Debian and Ubuntu derivatives:
    sudo apt install libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev pkg-config
On CentOS and recent Red Hat derivatives:
    sudo yum install libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pkgconfig
On Fedora derivatives:
    sudo dnf install libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pkgconf-pkg-config
On Arch Linux and derivatives:
    sudo pacman -S libx11 libxrandr libxinerama libxcursor libxi pkgconf
On Alpine:
    apk add libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev pkgconfig
On openSUSE:
    sudo zypper install libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pkg-config
On macOS:
    brew install pkg-config libx11 libxrandr libxinerama libxcursor libxix
Alternatively, when targeting the Wayland display server, use the packages listed in the GLFW documentation here:
https://www.glfw.org/docs/3.4/compile.html#compile_deps_wayland \n")
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

vcpkg_copy_pdbs()
