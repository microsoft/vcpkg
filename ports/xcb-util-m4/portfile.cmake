set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO util/xcb-util-m4
    REF  f662e3a93ebdec3d1c9374382dcc070093a42fed #v1.19.2
    SHA512 29840da449a434f169437fd2cef78273e0cba00a7f76d48790c838dc8f40fe55cb0932d96b649e1bd066c6c5e257dd2d9d71c663ce100aa5ca25a2ccec1b7e77
    HEAD_REF master
) 

file(GLOB_RECURSE M4_FILES "${SOURCE_PATH}/*.m4")
file(INSTALL ${M4_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/xorg/aclocal")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/xcb-util-m4/copyright")
