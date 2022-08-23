set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

if(NOT X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wayland/wayland-protocols
    REF  cd153943618bcf157896a6d0f1154d0ad62078a7 #1.23 
    SHA512 aae49d168e467d554ada638887511fa696a9fae900c93067d97f9e3d405068dc87883933f09ca2a3ef8a04631fdcffb629c178ec6e4c247f0c2ff6c1aaaaa952
    HEAD_REF master
)

set(ENV{ACLOCAL} "aclocal -I ${CURRENT_INSTALLED_DIR}/share/wayland/aclocal/")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()
if(EXISTS "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/")
    file(INSTALL "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/pkgconfig/")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
