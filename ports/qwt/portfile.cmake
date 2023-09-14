vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://git.code.sf.net/p/qwt/git"
    REF "06d6822b595b70c9fd567a4fe0d835759bf271fe"
    FETCH_REF qwt-6.2
    PATCHES 
        config.patch
        fix_dll_install.patch
)

string(COMPARE EQUAL  "${VCPKG_LIBRARY_LINKAGE}" "dynamic" IS_DYNAMIC)
set(OPTIONS "")
if(IS_DYNAMIC)
    set(OPTIONS "QWT_CONFIG+=QwtDll")
endif()
vcpkg_qmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    QMAKE_OPTIONS
        ${OPTIONS}
        "CONFIG-=debug_and_release"
        "CONFIG+=create_prl"
        "CONFIG+=link_prl"
)
vcpkg_qmake_install()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
