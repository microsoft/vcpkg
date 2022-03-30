vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF a243b23c1bdf9c6b00d1e48f208d603210516614
	SHA512 c666714fac9ccc692dd8de14252845c373fb13d6e16f02fd7b7ad1decc5f0b93a4b58ec06e7be5b79c89622725895a6a0296e4feb5202430772efb356267f56c
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
