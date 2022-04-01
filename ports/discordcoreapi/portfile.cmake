vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 61162e5ee6c021626d8d3109dbe1a87ba59f251d
	SHA512 5faef197cbeb89091c5f5459f0184be5a3a8659c609a732c6f5f0b88cfeaec778fde3800b36f616cb76f275f40f9b9d71d15bb570f06a9af69584624e50b763d
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
