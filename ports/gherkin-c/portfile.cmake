include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-libs/gherkin-c
    REF dd180edc7d092311f2e90a0c4957061156d39dd3
    SHA512 c6b38ab0e7a0fd1061d86b0ff9d9140f8c3d6f15cfc1673e947254c6c03a66d3e6aae5b267b074aa10fa30ba2850190c9e9ea7c12e340e4f8c5575b9bf31bab3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_GHERKIN_TESTS=OFF
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gherkin-c RENAME copyright)
