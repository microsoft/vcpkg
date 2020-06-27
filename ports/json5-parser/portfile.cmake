include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wlandry/json5_parser
    REF 1.0.0
    SHA512 105d0cccb28dd9045c06d73ab1e98a5e744ffdb38310a4581b8f1517b0edffb2cba424dc557a3490dfdcd4627d3bd1c6850eb38f588e1627dcab1de120d70717
    HEAD_REF master
	PATCHES 00001-fix-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/json5_parser
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/json5-parser)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/json5-parser/copyright COPYONLY)
