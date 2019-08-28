include(vcpkg_common_functions)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO fraillt/bitsery
	REF f85dff74151530fb05241877e3c80afab5891467
	SHA512 27dc79e80224f1429fccbbff75d9562e19db60a50567cb66c7999587cbf4a0b8344e3865ec804c63d05e041377dcc30de6fdc5ddfb99c779894ddd811f0d4a71
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

# Install license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/bitsery RENAME copyright)
