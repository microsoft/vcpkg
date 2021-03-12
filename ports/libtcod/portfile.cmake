vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtcod/libtcod
    REF 490f47daefa31f22581af72072010b3565113d92 # v1.16.6
    SHA512 5abf725b0db555e2bfc5848c9fa2960f42defe066c96fe1d3e42e8f7be6f0424f6b7f113edaf3ccc7156ee1ee57672fa198a9b09a122cf3d005ad02a3f6d38e8
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/LIBTCOD-CREDITS.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME libtcod-credits.txt)
