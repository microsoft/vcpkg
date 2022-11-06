vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gpg/libgpg-error
    REF libgpg-error-${VERSION}
    SHA512 f5a1c1874ac1dee36ee01504f1ab0146506aa7af810879e192eac17a31ec81945fe850953ea1c57188590c023ce3ff195c7cab62af486b731fa1534546d66ba3
    HEAD_REF master
    PATCHES
        add_cflags_to_tools.patch
        cross-tools.patch
        pkgconfig-libintl.patch
)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    set(ENV{AUTOPOINT} true) # true, the program
    vcpkg_list(APPEND options "--disable-nls")
endif()

if(VCPKG_CROSSCOMPILING)
    set(ENV{HOST_TOOLS_PREFIX} "${CURRENT_HOST_INSTALLED_DIR}/tools/libgpg-error/bin")
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        --disable-tests
        --disable-doc
        --disable-silent-rules
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

if("build-tools" IN_LIST FEATURES)
    file(INSTALL
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/mkerrcodes${VCPKG_TARGET_SUFFIX}"
            "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/mkheader${VCPKG_TARGET_SUFFIX}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/libgpg-error/bin"
        USE_SOURCE_PERMISSIONS
    )
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/debug/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(NOT "nls" IN_LIST FEATURES)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/locale")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
