vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git://git.gnupg.org/libgcrypt.git
    FETCH_REF libgcrypt-1.9.4
    REF 05422ca24a0391dad2a0b7790a904ce348819c10 # https://git.gnupg.org/cgi-bin/gitweb.cgi?p=libgcrypt.git;a=commit;h=05422ca24a0391dad2a0b7790a904ce348819c10
    HEAD_REF master
)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-doc
        --disable-silent-rules
        --with-libgpg-error-prefix=${CURRENT_INSTALLED_DIR}/tools/libgpg-error
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgcrypt/bin/libgcrypt-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgcrypt/debug/bin/libgcrypt-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
