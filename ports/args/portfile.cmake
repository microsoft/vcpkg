#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF 24868affc8f7f88ce8781bc6a21c5c7d5067c508
    SHA512 123e72a0f1d275de565443f818f37d3cf38ca43056802395aecf89d3cd913f628675c742cd136bf5cd25347ce783a34d938e2d97b6acf52e7479737dd0b8da33
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
