vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://git.code.sf.net/p/qwt/git"
    REF "907846e0e981b216349156ee83b13208faae2934"
    FETCH_REF qwt-6.2
    PATCHES
        config.patch
        fix_dll_install.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" IS_DYNAMIC)
set(OPTIONS "")
if(IS_DYNAMIC)
    list(APPEND OPTIONS "QWT_CONFIG+=QwtDll")
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

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-qwt-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-qwt")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
