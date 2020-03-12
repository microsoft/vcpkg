#vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux and Mac platform" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO file/file
    REF a0d5b0e4e9f97d74a9911e95cedd579852e25398
    SHA512 bd20a7f3a3117da10556a1f746f691d2e26b23b30cb70a6c08e05110eb415d457b82265dd910a7b05fc30bc34ba9019a33b1c59a34d844c14c2df7ba1eea060e
    HEAD_REF mater
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
)

vcpkg_install_make()

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man/man5)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
