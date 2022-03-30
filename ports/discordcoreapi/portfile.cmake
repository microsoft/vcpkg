vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF fdf59440dab88c343b9dd4de4caad2ddb5a35bf4
	SHA512 f1c2a25a32a28fc23c5f1b88dbd903dce1c4cf408c045acfcd817e8b8539b3957160fb936f41cfb5b7339fc3ebc7832a7f1326548132c7b32f9d3b873031af35
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	MAYBE_UNUSED_VARIABLES
	"${_VCPKG_INSTALLED_DIR}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
