#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Taywee/args
    REF 3de44ec671db452cc0c4ef86399b108939768abb
    SHA512 ba0f6d3f35ffd49a1c96bdd7f614dd1aea5644c1350d17986021fee92a6075e12fdb5711d098087475231cec90ccd7c2dcabf42ab8880b6645dac27d391275fc
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
