#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF a82a9d6c94d7c58d8b96c65bdc1aba09a4f3e5db
    SHA512 0a7caf231117827eb2dbbca3d51259c701c1b8da61518565e5cfe379edd03f34a2dac2d35cdba659042e19e7b3076ef4b6aa6e01d2f9b66db59d1672f9f18f12
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
