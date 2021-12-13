vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://git.code.sf.net/p/qwt/git"
    REF "a9ac6b28ee990f5d51ea36523057a5af54875e2e"
    PATCHES 
        config.patch
        fix_dll_install.patch
)

string(COMPARE EQUAL  "${VCPKG_LIBRARY_LINKAGE}" "dynamic" IS_STATIC)
set(OPTIONS "")
if(IS_STATIC)
    set(OPTIONS "QWT_CONFIG+=QwtDll")
endif()
vcpkg_qmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    QMAKE_OPTIONS
        ${OPTIONS}
        "CONFIG-=debug_and_release"
        "CONFIG+=create_prl"
        "CONFIG+=link_prl"
        #QWT_CONFIG += QwtDesigner
        #QWT_CONFIG += QwtPkgConfig
)
vcpkg_qmake_install()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)