#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF f68b7e186cd2a020cbddfe3194c1d8ddfeeb1013
    SHA512 affbda6f679257496de3d3f16db4d7e922ca39a0ef88f0c6b8a2803a7c89e7d12761fa8aa80e823e1c6b227936f1e3d5012b3ae82c0a64fb11179c74bb2e1d1c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/args)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/args/LICENSE ${CURRENT_PACKAGES_DIR}/share/args/copyright)

# Copy the args header files
file(INSTALL ${SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hxx")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/examples ${CURRENT_PACKAGES_DIR}/include/test)

vcpkg_copy_pdbs()
