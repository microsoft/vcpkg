vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO fraillt/bitsery
	REF db884a0656a3aabb87da1ae6edf12629507f76a7
	SHA512 7c94a09ed7cf07aa6c347d2960de622c5d69a25c7af501d10224b02f9db1bb191e8a5f7f096de488650f5a164e554b20f950fcdde423afced0ebfed249cb1c3d
	HEAD_REF master
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
