vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/Jsonifier
	REF fdf6036
	SHA512 86e5d4ea41cde563eeab476d73d5b68e80e5ebb98c69911a771a1a171a1c3ca3bf3247de6ed28d23ea625f3019458364312c8a0c4c7d30eacc8aac7813fd3321
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
