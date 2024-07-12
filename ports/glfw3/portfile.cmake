vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO glfw/glfw
    REF ${VERSION}
    SHA512 39ad7a4521267fbebc35d2ff0c389a56236ead5fa4bdff33db113bd302f70f5f2869ff4e6db1979512e1542813292dff5a482e94dfce231750f0746c301ae9ed
    HEAD_REF master
)

if(VCPKG_TARGET_IS_LINUX)
    file(READ "/etc/os-release" OS_RELEASE_CONTENT)

    set(tips "\n${PORT} currently requires the system libraries: X11 XRandR Xinerama Xcursor XInput pkg-config. \nYou might be able to install them by the following command:\n")
    if(OS_RELEASE_CONTENT MATCHES "ID=debian|ID=ubuntu")
        string(APPEND tips "  sudo apt install libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev pkg-config")
    elseif(OS_RELEASE_CONTENT MATCHES "ID=centos|ID=\"rhel\"")
        string(APPEND tips "  sudo yum install libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pkgconfig")
    elseif(OS_RELEASE_CONTENT MATCHES "ID=fedora")
        string(APPEND tips "  sudo dnf install libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pkgconf-pkg-config")
    elseif(OS_RELEASE_CONTENT MATCHES "ID=arch")
        string(APPEND tips "  sudo pacman -S libx11 libxrandr libxinerama libxcursor libxi pkgconf")
    elseif(OS_RELEASE_CONTENT MATCHES "ID=alpine")
        string(APPEND tips "  apk add libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev pkgconfig")
    elseif(OS_RELEASE_CONTENT MATCHES "ID=\"opensuse\"")
        string(APPEND tips "  sudo zypper install libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pkg-config")
    endif()
    
    message("${tips}\n")
elseif(VCPKG_TARGET_IS_OSX)
    message("\n${PORT} currently requires the system libraries: X11 XRandR Xinerama Xcursor XInput pkg-config. \nYou might be able to install them by the command:\n
    brew install pkg-config libx11 libxrandr libxinerama libxcursor libxix\n")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    wayland         GLFW_BUILD_WAYLAND
)

if("wayland" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
       message("When targeting the Wayland display server, use the packages listed in the GLFW documentation here:
https://www.glfw.org/docs/3.3/compile.html#compile_deps_wayland \n") 
    endif()
endif()

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
