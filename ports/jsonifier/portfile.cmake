vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/Jsonifier
	REF a8cf61e
	SHA512 d5c87a21d130a64238b7b0a37f4e6ca3904832c0a8ca252eb19ffbc70b0cd124fb67d76e69e65b8e0d2b5187f5b186a2997977d7e5e460c884a3f69dc050ca1
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
