include(vcpkg_common_functions)

vcpkg_from_github( 
    OUT_SOURCE_PATH SOURCE_PATH 
    REPO danfis/libccd
    REF 64f02f741ac94fccd0fb660a5bffcbe6d01d9939
    SHA512 901b09d57e119e4661b3556bbefe5a4d58cb843bff5c76ee3952fe379ff183c878a04e86e6192006c11012309c6e93d42319e9d606abdf7ad723f6d8afeea47f
    HEAD_REF master 
) 

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_fix_symbols_export.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/ccd")

file(INSTALL ${SOURCE_PATH}/BSD-LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ccd RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/doc)
