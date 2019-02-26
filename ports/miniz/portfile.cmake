include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO richgel999/miniz
    REF 2.0.8
    SHA512 84b480df8bff63422d8c36cef3741f9b9f3dce13babf4de6cb4d575209978ad849357cc72bcf31ee8b6c5da6853ed2e5eddbbe16fecd689afd7028e834abf7e9
    HEAD_REF master
    PATCHES
    	CMakeLists-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/miniz RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME miniz)
