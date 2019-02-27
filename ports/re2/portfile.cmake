include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF 98ad734aae9996a6dd1aa1fec72e800d621acd51
    SHA512 e28a6b3428ca2714a48194f82f9d6ea4c56b3d4bc776bf3b9402bc081ca8d667f37f4ce98cd89ed1077998f945f1eebee1f501a1acdcb1fb16e741643bc8d8ab
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DRE2_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/re2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
