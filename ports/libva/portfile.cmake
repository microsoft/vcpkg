vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO intel/libva
    REF "${VERSION}"
    SHA512 cd633e5e09eac1ed10f1fc12b0f664f836e0eda9e47c17e1295b746cfd643a18fd0564a06a148ced3cf1e2321aa4d21275918bcf8c717d3981e98a598179f370
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    x11             WITH_X11
    wayland         WITH_WAYLAND
    glx            WITH_GLX
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
