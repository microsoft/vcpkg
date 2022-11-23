if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxcb-render-util
    REF  5293d8b6165f23b9f7a8bcc903da0e4d7a75984c #v 0.3.10
    SHA512 ecd1876b62c1345ce3c06ac525f1af4f59dcce3c8d76003c59dd64c80f7787d6d2754c481e585507d6bcaf443026a7aa22ab9eac28b5153eff78d216e53eb29f
    HEAD_REF master # branch name
    PATCHES pthread.patch # required since this port directly depends on pthread functions. So it has to directly link it!
) 
file(TOUCH "${SOURCE_PATH}/m4/dummy")
set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
