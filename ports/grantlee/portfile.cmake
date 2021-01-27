vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO steveire/grantlee
    REF v5.2.0 # v5.2.0
    SHA512 80b728b1770f60cd574805ec6fee8c6b86797da44c53f7889d3256cc52784e2cc5b7844e648f35f5cebbb82e22eed03dccf9cd7d0bdefdac9821e472d1bbbee3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Grantlee5)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
