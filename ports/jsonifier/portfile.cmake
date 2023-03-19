vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/Jsonifier
	REF 0630368
	SHA512 dd9ca075acfebb6590e5344c00049a391c94db06ff17e7fc9c33626fb07a26f37c9b113e0d369495cf14179eace94d131dca2a5c78cd9a5f81fa8e0737cd8775
	HEAD_REF Dev
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
