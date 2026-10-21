set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_gitlab(
    GITLAB_URL "https://gitlab.freedesktop.org/xorg"
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "util/xcb-util-m4"
    REF c617eee22ae5c285e79e81ec39ce96862fd3262f
    SHA512 d2d977574a106ca59207988e3e4ec12ecbcf30852df46456f7ec5284983e49f31ee85025f404d863f8e3d766f193e6a79508f26a3dcd33173d7bbefccdb279fa
    HEAD_REF master
)

file(GLOB_RECURSE M4_FILES "${SOURCE_PATH}/*.m4")
file(INSTALL ${M4_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/xcb-util-m4/copyright")
