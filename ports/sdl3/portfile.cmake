if(VCPKG_TARGET_IS_LINUX)
    set(system_packages "")
    if("x11" IN_LIST FEATURES)
        list(APPEND system_packages
            libx11-dev libxext-dev libxcursor-dev libxi-dev libxfixes-dev
            libxrandr-dev libxrender-dev libxtst-dev libthai-dev
        )
    endif()
    if("x11-xscrnsaver" IN_LIST FEATURES)
        list(APPEND system_packages libxss-dev)
    endif()
    if("wayland" IN_LIST FEATURES)
        list(APPEND system_packages libwayland-dev libxkbcommon-dev libegl-dev libdecor-0-dev)
    endif()
    if("kmsdrm" IN_LIST FEATURES)
        list(APPEND system_packages libdrm-dev libgbm-dev libegl-dev)
    endif()
    if("sndio" IN_LIST FEATURES)
        list(APPEND system_packages libsndio-dev)
    endif()
    if("udev" IN_LIST FEATURES)
        list(APPEND system_packages libudev-dev)
    endif()
    if("ibus" IN_LIST FEATURES)
        list(APPEND system_packages libibus-1.0-dev)
    endif()
    if(system_packages)
        list(REMOVE_DUPLICATES system_packages)
        list(JOIN system_packages " " system_packages)
        message(STATUS
            "${PORT} currently requires the following development packages from the system package manager.\n"
            "These can be installed on Ubuntu systems via:\n"
            "    sudo apt install ${system_packages}"
        )
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL
    REF "release-${VERSION}"
    SHA512 12fcb5592016b27922b08d1580d75f5f15c72e67cf04415e2bd824dc7563ac940c25bbe368b03d0a755f5832803049467e3d0ee6784ed3684792bc4d7741af50
    HEAD_REF main
    PATCHES
        fix-freebsd.patch
        libusb-pkgconfig.patch
        require-dependencies.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SDL_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" FORCE_STATIC_VCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        alsa           SDL_ALSA
        dbus           SDL_DBUS
        ibus           SDL_IBUS
        jack           SDL_JACK
        kmsdrm         SDL_KMSDRM
        liburing       SDL_LIBURING
        libusb         SDL_HIDAPI_LIBUSB
        pipewire       SDL_PIPEWIRE
        pulseaudio     SDL_PULSEAUDIO
        sndio          SDL_SNDIO
        udev           SDL_LIBUDEV
        vulkan         SDL_VULKAN
        wayland        SDL_WAYLAND
        wayland        SDL_WAYLAND_LIBDECOR
        x11            SDL_FRIBIDI
        x11            SDL_LIBTHAI
        x11            SDL_X11
        x11            SDL_X11_XCURSOR
        x11            SDL_X11_XDBE
        x11            SDL_X11_XFIXES
        x11            SDL_X11_XINPUT
        x11            SDL_X11_XRANDR
        x11            SDL_X11_XSHAPE
        x11            SDL_X11_XSYNC
        x11            SDL_X11_XTEST
        x11-xscrnsaver SDL_X11_XSCRNSAVER
)

if (VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_check_features(OUT_FEATURE_OPTIONS EMSCRIPTEN_FEATURE_OPTIONS
        FEATURES
            emscripten-pthreads     SDL_PTHREADS
    )
    vcpkg_list(APPEND FEATURE_OPTIONS "${EMSCRIPTEN_FEATURE_OPTIONS}")
endif()

if ("macos-keyboard-grab" IN_LIST FEATURES)
    # SDL only disables the system shortcuts in SDL_SetWindowKeyboardGrab() on
    # macOS if SDL_MAC_NO_SANDBOX is defined
    string(APPEND VCPKG_C_FLAGS " -DSDL_MAC_NO_SANDBOX")
    string(APPEND VCPKG_CXX_FLAGS " -DSDL_MAC_NO_SANDBOX")
endif()

# option for not need to show windows
list(APPEND FEATURE_OPTIONS -DSDL_UNIX_CONSOLE_BUILD=ON)
if (VCPKG_TARGET_IS_LINUX AND NOT "x11" IN_LIST FEATURES AND NOT "wayland" IN_LIST FEATURES AND NOT "kmsdrm" IN_LIST FEATURES)
    message(WARNING "The selected features don't allow sdl3 to create windows, which is usually unintentional. You can get video support by installing the x11, wayland and/or kmsdrm features.")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSDL_STATIC=${SDL_STATIC}
        -DSDL_SHARED=${SDL_SHARED}
        -DSDL_FORCE_STATIC_VCRT=${FORCE_STATIC_VCRT}
        -DSDL_LIBC=ON
        -DSDL_ALSA_SHARED=OFF # Link the dependency supplied by the alsa port.
        -DSDL_FRIBIDI_SHARED=OFF # Link the dependency supplied by the fribidi port.
        -DSDL_HIDAPI_LIBUSB_SHARED=OFF # The libusb port controls libusb's linkage.
        -DSDL_JACK_SHARED=OFF # The jack2 port supplies a shim that loads the system JACK implementation.
        -DSDL_PIPEWIRE_SHARED=OFF # The pipewire port controls PipeWire's linkage.
        -DSDL_PULSEAUDIO_SHARED=OFF # The pulseaudio port controls PulseAudio's linkage.
        -DSDL_ROCKCHIP=OFF # Requires a device-specific vendor Mali graphics stack.
        -DSDL_RPI=OFF # Requires the legacy Broadcom bcm_host/brcmegl graphics stack.
        -DSDL_TEST_LIBRARY=OFF
        -DSDL_TESTS=OFF
        -DSDL_INSTALL_CMAKEDIR_ROOT=share/${PORT}
        -DSDL_REVISION=vcpkg # Skip invoking git to determine the revision.
    MAYBE_UNUSED_VARIABLES
        SDL_FORCE_STATIC_VCRT
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE.txt"
        "${SOURCE_PATH}/src/hidapi/LICENSE-bsd.txt"
        "${SOURCE_PATH}/src/video/stb_image.h"
        "${SOURCE_PATH}/src/video/yuv2rgb/LICENSE"
        "${SOURCE_PATH}/include/SDL3/SDL_opengles2_gl2.h"
        "${SOURCE_PATH}/include/SDL3/SDL_opengles2_gl2platform.h"
    COMMENT "SDL_opengles2_gl2platform.h is licensed under Apache-2.0; see https://www.apache.org/licenses/LICENSE-2.0."
)
