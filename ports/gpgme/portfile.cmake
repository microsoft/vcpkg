vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports unix platform" ON_TARGET "Windows")

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
    SOURCE_PATH ${SOURCE_PATH}
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Gpgmepp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
