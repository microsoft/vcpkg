vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO fraillt/bitsery
 REF c555088aa39f555341a0b20f12379eb9c1120ae4 # v5.0.1
	SHA512 8714ca62158c52209df5e3448259ab614103f7183f9a9306dd5ecf18dec588ceefe18bdf96383039850c807a24eaa77e2dda54d23ea89fefada017808641d59f
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
