vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcvt
    REF db5ff12110994dc9010d44f981399e796917a845
    SHA512  81472455e3ce5645b8b0aa79222e9fc5de92f09429bf9a1641de259b8152253fda59abbcde97c99f59f313e9a571f2545e9420d7ba5ee9a38f70302fdce09f53
    HEAD_REF master
) 
vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES cvt AUTO_CLEAN)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
