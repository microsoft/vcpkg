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
            gettext.patch
)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")

if(NOT TARGET_TRIPLET STREQUAL HOST_TRIPLET)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/libgpg-error")

    if (VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string(
            "${SOURCE_PATH}/src/Makefile.am"
            [=[./mkheader$(EXEEXT_FOR_BUILD)]=]
            [=[mkheader.exe]=]
        )
        vcpkg_replace_string(
            "${SOURCE_PATH}/src/Makefile.am"
            [=[./mkerrcodes$(EXEEXT_FOR_BUILD)]=]
            [=[mkerrcodes.exe]=]
        )
    endif()
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-tests
        --disable-doc
        --disable-silent-rules
        ${EXEEXT_FOR_BUILD}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libgpg-error/debug/bin/gpg-error-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")

    if(TARGET_TRIPLET STREQUAL HOST_TRIPLET )
        vcpkg_copy_tools(TOOL_NAMES mkheader mkerrcodes SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/locale" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
