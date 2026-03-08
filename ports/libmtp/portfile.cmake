vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libmtp/libmtp
    REF ${VERSION}
    FILENAME "libmtp-${VERSION}.tar.gz"
    SHA512 97094b29073681da0c714b6c4aea2e5f35253a8d06229e60c0af46727413470e9da6be422d873449fc4dec6f9b8efce6d3edc657b9251182cc0a709859e99baa
    PATCHES
        disable-examples.patch
        dont-install-def-file.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/m4/iconv.m4")
file(REMOVE_RECURSE "${SOURCE_PATH}/src/gphoto2-endian.h")

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")
set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_HOST_INSTALLED_DIR}/share/gettext/aclocal/\"")

if(VCPKG_CROSSCOMPILING AND VCPKG_TARGET_IS_ANDROID)
    set(cross_flags "--with-udev=${CURRENT_HOST_INSTALLED_DIR}/lib/udev/"
                    "--enable-crossbuilddir=${CURRENT_INSTALLED_DIR}/lib/udev/"
                    "HOST_MTP_HOTPLUG=${CURRENT_HOST_INSTALLED_DIR}/tools/libmtp/bin/mtp-hotplug${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${cross_flags}
        --disable-mtpz
        --disable-doxygen
)
vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
