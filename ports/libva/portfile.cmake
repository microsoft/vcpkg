vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/libva
    REF "${VERSION}"
    SHA512 03e3648b43a0c82c7840203d0b6286879317667ad9d4cf8d7813a29023ffebaf6cd5719a1a9f5fb0f2671738bd675c69a08fd27aa73b7339c8524a8f794150bc
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    x11             WITH_X11
    wayland         WITH_WAYLAND
    glx             WITH_GLX
)

message(WARNING "You will need to install libdrm dependencies to use this port:\nsudo apt install libdrm-dev\n")

if ("x11" IN_LIST FEATURES)
    message(WARNING "You will need to install Xorg dependencies to use feature x11:\nsudo apt install libx11-dev libxext-dev libxfixes-dev libx11-xcb-dev libxcb-dri3-dev\n")
endif()
if ("wayland" IN_LIST FEATURES)
    message(WARNING "You will need to install Wayland dependencies to use feature wayland:\nsudo apt install libwayland-dev\n")
endif()
if ("glx" IN_LIST FEATURES)
    message(WARNING "You will need to install GLX dependencies to use feature glx:\nsudo apt install libglu1-mesa-dev\n")
endif()
if(WITH_X11)
    list(APPEND options -Dwith_x11=yes)
else()
    list(APPEND options -Dwith_x11=no)
endif()

if(WITH_WAYLAND)
    list(APPEND options -Dwith_wayland=yes)
else()
    list(APPEND options -Dwith_wayland=no)
endif()

if(WITH_GLX)
    list(APPEND options -Dwith_glx=yes)
else()
    list(APPEND options -Dwith_glx=no)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${options}
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
