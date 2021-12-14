vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kafeg/optimus-cpp
    REF d77f95a553fed6eda43b7aae6c6e59ce27a26e6f
    SHA512 1e34aa5aa65a3fc2bbbd900c2fe83ee0e19697d2a1bf3cc7495609a1f9fb27bd0f76373726a6cbde482532d9ad3de0d4eac92c3a4fd2fee81c3d9fe2848ec604
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
