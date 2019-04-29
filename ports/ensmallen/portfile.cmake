include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF ensmallen-1.14.2
    SHA512 8aa8d00d80579c619e417d8fbc17c78c867f916161e3c412c3af24c1b7b9816c9e6faee981931e1591a45db0c797a081d45f1dfc3ea396a610ee2da55232b265
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
