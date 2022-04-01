vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 168888433ff0244b0227073a5d1e48f06c7b4deb
	SHA512 8708b15eaaa2ddcf2a93b04d8e75e548f06e4e99a92802f4d523ec62d520c1a7619990dd7c8455791c0782e66af9ba030b5172f05aad2637de497a8cfcdeedc1
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
