vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libdc1394/libdc1394-2
    REF "${VERSION}"
    FILENAME "libdc1394-${VERSION}.tar.gz"
    SHA512 0d0b1861612f7c69753af7109ef226ea4e550353222e02663dfaac3fa8f456b94c2dd2579cac840047a42bac97692da436f10be3def1fa29109de05c1e871257
    PATCHES
        fix-macosx.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "--disable-examples"
        ac_cv_lib_raw1394_raw1394_channel_modify=no
        ac_cv_path_SDL_CONFIG=no
)
vcpkg_install_make()

file(APPEND "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libdc1394-2.pc" "\nRequires.private: libusb-1.0\n")
if(NOT VCPKG_BUILD_TYPE)
    file(APPEND "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libdc1394-2.pc" "\nRequires.private: libusb-1.0\n")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
