vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Naios/function2
    REF 3a0746bf5f601dfed05330aefcb6854354fce07d # 4.1.0
    SHA512 48dd8fb1ce47df0835c03edf78ae427beebfeeaaabf6b993eb02843f72cce796ba5d1042f505990f29debd42bc834e531335484d45ca33e841657e9ff9e5034f
    HEAD_REF master
    PATCHES
        disable-testing.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE ${CURRENT_PACKAGES_DIR}/Readme.md)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Put the installed licence file where vcpkg expects it
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

vcpkg_copy_pdbs()
