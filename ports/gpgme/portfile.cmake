
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gpg/gpgme
    REF gpgme-1.14.0
    SHA512 b4608fd1d9a4122d8886917274e323afc9a30494c13a3dea51e17e9779f925bf8d67e584434d6a13018f274a6cbcf0a5e36f2fea794a065906bbb556b765398e
    HEAD_REF master
    PATCHES
       disable-tests.patch
       disable-docs.patch
)

list(REMOVE_ITEM FEATURES core)
string(REPLACE ";" "," LANGUAGES "${FEATURES}")

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-gpgconf-test
        --disable-gpg-test
        --disable-gpgsm-test
        --disable-g13-test
        --enable-languages=${LANGUAGES}
        --with-libgpg-error-prefix=${CURRENT_INSTALLED_DIR}/tools/libgpg-error
        --with-libassuan-prefix=${CURRENT_INSTALLED_DIR}/tools/libassuan
)

vcpkg_install_make()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Gpgmepp)
vcpkg_copy_pdbs() 
# We have no dependency on glib, so remove this extra .pc file
file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gpgme-glib.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gpgme-glib.pc")
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gpgme/bin/gpgme-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
if (NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/gpgme/debug/bin/gpgme-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
