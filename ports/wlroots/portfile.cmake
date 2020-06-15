message("wlroots currently requires the following libraries from the system package manager:
    wayland
    wayland-protocols
    EGL
    GLESv2
    libdrm
    GBM
    libinput
    xkbcommon
    udev
    pixman
    systemd (optional, for logind support)
    elogind (optional, for logind support on systems without systemd)

If you choose to enable X11 support:
    
    xcb
    xcb-composite
    xcb-xfixes
    xcb-xinput
    xcb-image
    xcb-render
    x11-xcb
    xcb-errors (optional, for improved error reporting)
    x11-icccm (optional, for improved Xwayland introspection)")

vcpkg_fail_port_install(
  MESSAGE "Only Linux is supported by wlroots"
  ON_ARCH x86 arm arm64
  ON_TARGET WINDOWS UWP ANDROID FREEBSD OSX
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO swaywm/wlroots
    REF 0c7c562482575cacaecadcd7913ef25aeb21711f # 0.10.1
    SHA512 3b464041331e0f61386200bb89ba3c603f5bd37545bf1c3413ba2be03d684e5187466b4fa4821a701c2148191a7f933ec087bc148467f7f5b2a04c23f21a0bcf
    HEAD_REF master
    PATCHES use-system-wayland-data.patch
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --backend=ninja
        "-Dvcpkg_installed_dir=${CURRENT_INSTALLED_DIR}"
)

vcpkg_install_meson()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
