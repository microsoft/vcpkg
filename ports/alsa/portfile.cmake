if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "Package only supports Linux platform.")
endif()

message(
"alsa currently requires the following libraries from the system package manager:
    autoconf libtool
These can be installed on Ubuntu systems via sudo apt install autoconf libtool"
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alsa-project/alsa-lib
    REF v1.2.5.1
    SHA512 1c8613e520bd24ec2332b677a35d1c49171781f6408be61c79ec90d143d424d8df6e1c9e22e082d331022e0fe858145f7ea214a7b731ed5e306762194b49d50e
    HEAD_REF master
    PATCHES
        0001-control-empty-fix-the-static-build.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_OPTS --enable-shared=yes --enable-static=no)
else()
    set(BUILD_OPTS --enable-shared=no --enable-static=yes)
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${BUILD_OPTS}
        --disable-python
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools/alsa/debug")

configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
