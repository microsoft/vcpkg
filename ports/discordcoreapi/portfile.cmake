vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 18e6ef13b15d3e2b8e6b1ae059899b5f974d512d
	SHA512 2684f5ea0d905bcbf952f1c2310f2a03ee9676c2c0c580a56f846fae81304454078138362c5427fac2ed8978ee5032dda823b3b3b3ed41f1edf905ff7b75b3ea
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
