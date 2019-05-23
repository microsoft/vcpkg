include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF ensmallen-1.15.0
    SHA512 4264bbba856e8fd4fb00d8a4e5f90d93b853d5358cea0ab7231f38d22af3b1e22b238af03edf292086937c16fe7575549d0a1e4fba1d49c85452ec1d3cc9f31a
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
