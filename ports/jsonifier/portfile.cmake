vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/Jsonifier
	REF ddfb0a5
	SHA512 7a80e8676e7f2d65f34dbb3dd30f3bd004d38fe5632213e33fc9c1b0dfa05cd564c83b3b47c9412e75173fe4f7572b50544fa3aa9ccb6e3ca50b716376b8fbe5
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(
	INSTALL "${SOURCE_PATH}/License.md"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
