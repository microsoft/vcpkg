
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gcc-mirror/gcc
    REF releases/gcc-${VERSION}
    SHA512 5fcc2c33cd1a535e0ac07677cafe8054efbf28182eeae61cc2e6d91e73e663302671f32bdf6ab25c883fe95de1f70a362e6189af4fa1f48d7725f2c5b634b974
    HEAD_REF master
    PATCHES
        disable_autoconf_check.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    set(OPTIONS "CXXFLAGS=-Zc:__cplusplus")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --enable-languages=c,c++
        --disable-multilib
        ${OPTIONS}
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
