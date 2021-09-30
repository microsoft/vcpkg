if (VCPKG_TARGET_IS_WINDOWS)
    set (PATCHES SMP.patch msvc.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gpg/libgpg-error
    REF libgpg-error-1.42
    SHA512 f5a1c1874ac1dee36ee01504f1ab0146506aa7af810879e192eac17a31ec81945fe850953ea1c57188590c023ce3ff195c7cab62af486b731fa1534546d66ba3
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
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

if (VCPKG_TARGET_IS_WINDOWS)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/gpg-error.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/gpg-errord.lib")
    endif()
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/debug/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/locale" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
