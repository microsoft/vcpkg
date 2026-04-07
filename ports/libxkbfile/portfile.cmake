if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

set(PATCHES "")
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(PATCHES symbol_visibility.patch)
    list(APPEND VCPKG_C_FLAGS "/DXKBFILE_BUILD")
    list(APPEND VCPKG_CXX_FLAGS "/DXKBFILE_BUILD")
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxkbfile
    REF  "libxkbfile-${VERSION}"
    SHA512 e4b0fc6d9525669fe85cd8ebb096ce4a9355de00e7356dbe6c3cb194f6aa2449ef345811ce4934bb8c09edb94eee08227f7f20ee1df4a8a49697a3dc85cd704e
    HEAD_REF master
    PATCHES
        fix_u_char.patch
        ${PATCHES}
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
