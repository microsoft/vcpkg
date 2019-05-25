include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF 8bea8d214b40be3cb42e817328c0791541fbcd6c
    SHA512 0fe8ac487fe5f116e08bb3893b26b82fafa132dbd7c8a740312cf86ea7a8334471c84ac51839d59c4500ce74ad19131c8a2e33bd0ac21c2504f9e8b30182e2b4
    HEAD_REF master
	PATCHES
		disable_tests.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYRIGHT.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ensmallen RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
