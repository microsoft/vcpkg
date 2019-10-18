vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux and Mac platform" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO threatstack/libmagic
    REF 5.18
    SHA512 2e795a9ee2a75d841a175d61e80bd1ac9b4d0e3a809e57469e10d1d8a5f492ece1750b5966e7c300a2db2cc943521499131c1eba72c92390e4a73a1824de6480
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
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
