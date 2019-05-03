include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 653f9e2a6a17bcdf8dba2b3f8671aa8880efca29
    SHA512 2411904082662c60e05c97d3a0de6e5d9f9654a8703e4e520eba1018a3542670db81f2b78ff9ee3267bb9c1b24e4c6a9b5b35b0f62836198ac152acb4b37c744
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DRE2_BUILD_TESTING=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/re2 TARGET_PATH share/re2)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/re2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
