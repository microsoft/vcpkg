vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux and Mac platform" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO threatstack/libmagic
    REF 1249b5cd02c3b6fb9b917d16c76bc76c862932b6
    SHA512 36c55d1d3956f72490d3e57375cc4a951de9689fdad5ae80e660724c62ea9086d5ce47fcecf823fd6ea6d6d2bce46920d408d3d59b25fe3a53787861de7540f8
    HEAD_REF mater
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    NO_DEBUG
)

vcpkg_install_make()

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)