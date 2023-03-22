vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/Jsonifier
	REF 37c96a7
	SHA512 c2d0ad1b2f82c5d31de82bd2bca48c8f163a52d95e58efd047e73a743200bc92e0f9a6d9b3236fe3e2e5c90f0bce2d66df6cf71853a7e875ef8999e46b74963a
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
