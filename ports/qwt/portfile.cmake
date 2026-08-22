vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qwt/qwt
    REF ${VERSION}
    FILENAME "qwt-${VERSION}.zip"
    SHA512 4008c3e4dace0f18e572b473a51a293bb896abbd62b9c5f0a92734b2121923d2e2cbf67c997b84570a13bf4fdd7669b56497c82fbae35049ed856b2f0a65e475
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

# Qt6 pkg-config files not installed https://github.com/microsoft/vcpkg/issues/25988
# vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-qwt-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-qwt")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
