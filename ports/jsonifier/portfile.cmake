vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/Jsonifier
	REF 52efa6d
	SHA512 422d34cdb0be26516560613d6ab80e1c05647600bd93a09732d6fdc509caa9cf247f6d45043a76cb0f030d2343c1139e07a0f3d78a7cf4b3eab17f4bab9a66ed
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
