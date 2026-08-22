vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gul-cpp/gul14
    REF "v${VERSION}"
    SHA512 50e20163ac0d29b80eb5b7fef3d57ccb8c649096414f432d613a900d8c420aa6847b1f2e47fb34571efc614d965ef265796b29ebf45bc99809ae8c505315c3bc
    HEAD_REF main
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dtests=false
)

vcpkg_install_meson()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

# Install copyright file
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.txt")
