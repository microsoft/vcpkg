include(vcpkg_common_functions)

set(DEVIL_VERSION 1.8.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DentonW/DevIL
    REF v${DEVIL_VERSION}
    SHA512 4aed5e50a730ece8b1eb6b2f6204374c6fb6f5334cf7c880d84c0f79645ea7c6b5118f57a7868a487510fc59c452f51472b272215d4c852f265f58b5857e17c7
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}/DevIL
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_fix-encoding.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002_fix-missing-mfc-includes.patch
        ${CMAKE_CURRENT_LIST_DIR}/enable-static.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/DevIL
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/devil RENAME copyright)
