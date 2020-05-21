include(vcpkg_common_functions)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO fraillt/bitsery
 REF d24dfe14f5a756c0f8ad3d56ae6949ecc2c99b2e # v5.0.3
	SHA512 0bd4c80632640b74387587f85ca6e174aed2efd1dc1d83dd682e26e10aa9ef9a98b5477cfb78aa9cbb1a4112fc12468d7072b5c237f32f6738158ba21cf2ea39
	HEAD_REF master
	PATCHES fix-install-paths.patch
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
)

vcpkg_install_cmake()

# Delete redundant and empty directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
