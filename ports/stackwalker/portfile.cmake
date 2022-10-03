vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JochenKalmbach/StackWalker
    REF 53320512bd2fe1097b85e38262191d7c55210990
    SHA512 06ee02855c2f0f0d5176f2edc95f704b7ab721a80e26cdb5cc037f7abb98bcd2318ffe23934ad2f1289e69d5a835eb24c496e2e1cecccd442ed107ab4fda28fc
    HEAD_REF master
    PATCHES
		${CMAKE_CURRENT_LIST_DIR}/install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DStackWalker_DISABLE_TESTS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/stackwalker)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
