include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cyan4973/xxHash
    REF v0.6.4
    SHA512 6c914bac5092dfd01349c8223c382d3c13ba1b22e08300ce86ea9663a9a934f930debdeb71c14365ec57d72b95088a4354da92dfb7fcf7d07ec01c0f4fb70ca7
    HEAD_REF dev)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake_unofficial
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xxhash)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xxhash/LICENSE ${CURRENT_PACKAGES_DIR}/share/xxhash/copyright)
