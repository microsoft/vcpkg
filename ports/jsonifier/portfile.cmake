vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/Jsonifier
	REF c9b4a12
	SHA512 c96794b9c319e924ff672d381fb6f3f3a43aac1530ecec798b03404018ca279d078b416c620eae37e1f3be88429231938242c5ab4574486b8acbe6410b0b202b
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
