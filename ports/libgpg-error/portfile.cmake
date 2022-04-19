if (VCPKG_TARGET_IS_WINDOWS)
    set (PATCHES SMP.patch msvc.patch)
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git://git.gnupg.org/libgpg-error.git
    FETCH_REF libgpg-error-1.45
    REF dbac537e5e865fb6f3aa8596d213aa8c47a9dea1 # https://git.gnupg.org/cgi-bin/gitweb.cgi?p=libgpg-error.git;a=commit;h=dbac537e5e865fb6f3aa8596d213aa8c47a9dea1
    HEAD_REF master
    PATCHES ${PATCHES}
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-tests
        --disable-doc
        --disable-silent-rules
)

vcpkg_install_make()

if (VCPKG_TARGET_IS_WINDOWS)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/gpg-error.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/gpg-errord.lib")
    endif()
endif()

vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/debug/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/locale" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
