#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF 7bf17000aa0969b8ca3178c72ec834b105944a41
    SHA512 38f038f2ea3cdbf62678112a28f6b9a2b46b7b291ec9a7c78393c28b1169dc393a086393f24534804188d434583896d9eaedca964c00a2db032fb337ebc9c214
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/license DESTINATION ${CURRENT_PACKAGES_DIR}/share/args)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/args/license ${CURRENT_PACKAGES_DIR}/share/args/copyright)

# Copy the args header files
file(INSTALL ${SOURCE_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.hxx")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/examples ${CURRENT_PACKAGES_DIR}/include/test)

vcpkg_copy_pdbs()
