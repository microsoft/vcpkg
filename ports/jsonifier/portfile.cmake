vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/Jsonifier
	REF 440eaa0
	SHA512 4d5aa301a6428a48e9feb53044771e0ea23c166db2dac4435b5332a9fc192efca05fa4329c1a0293bb08f1415af7aa21cd38d0422af3138fb8d58ee10ec17d98
	HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")