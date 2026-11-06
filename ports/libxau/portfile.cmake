if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_from_gitlab(
    GITLAB_URL "https://gitlab.freedesktop.org/xorg"
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "lib/libxau"
    REF "libXau-${VERSION}"
    SHA512 d76ea5a7d5f70159b3d40242cee66b4a763b98ce57b0b5660ce47cac9bc240d51fb20eec969f8fffdfd79fa46ec8e1b9bf2aa4ca9d39d1f45d515e75afb23a7d
    HEAD_REF master
)
file(MAKE_DIRECTORY "${SOURCE_PATH}/m4")

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
