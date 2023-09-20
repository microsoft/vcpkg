vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/VulkanSceneGraph
    REF "v${VERSION}"
    SHA512 79ea02c5816c6b99ce847938d9004e0078cb685523c720d4abce5136b91bf4d17fff52893eba972ce9ac3d6db7fe92581039cba6ef72fb9e44ff37f9d9b314f3
    HEAD_REF master
	PATCHES devendor-glslang.patch
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "vsg" CONFIG_PATH "lib/cmake/vsg")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
