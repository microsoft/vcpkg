vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 9f8af315ab9fc3c12aaa59dce4a9f9bc22ead775
	SHA512 7c76decb7acfa208c44bbd46dc087a0f87c098ea0ab0c8dfedd89f5b09bd4cd211e3730711fc1475f0ff8552904c46da2e1f4b7790e6ea0b4a605db0baf80dde
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
