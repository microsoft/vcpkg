vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 33481be6ac8c0ad5cab9c50213af3de49980bb1b
	SHA512 03824f69cdc7a907a53c770fa0de529e3f9e53f78e6850757fe2b179631d883c8bae5fc5dea0b3d9e2a67078e3c3c75639edf989eb5b564572b12df4291ab3f4
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
