vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcvt
    REF db5ff12110994dc9010d44f981399e796917a845
    SHA512 a69c4d163ab7a5f71dd4940e9b1f7ac2c5b5f282cbe9e1af26dcb677d061ff5187aa17f9acf9f913d3b05afac44f44b962ca4290ad2f5ae7f104ec870d8b515f
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
