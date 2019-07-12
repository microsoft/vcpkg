include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyobjloader
    REF 9d9594598a99d4d7d7039bc504f7b05b490596c4
    SHA512 2a210c1610acf9a75ce66115ae28f67106135421ca1668f1f88f32f38a752698bfce20aef767f866beb71da348783e49ccc814ac8fdc868a99e0968ac0b38d2a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DCMAKE_INSTALL_DOCDIR:STRING=share/tinyobjloader
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/tinyobjloader/cmake)

file(
    REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/tinyobjloader
    ${CURRENT_PACKAGES_DIR}/debug/lib/tinyobjloader
)

vcpkg_copy_pdbs()

# Put the licence file where vcpkg expects it
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/LICENSE ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/copyright)
