vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO apple/coremltools
	REF "${VERSION}"
	SHA512 87f90835e214738fdb8d61143732be04f9a9bc68b9cb06ccbfe27c77828174d58da5118d0a1adf52326477ff8b8047c3ae4cede5ecd0b937809d20dc68917970
	HEAD_REF main
	PATCHES
		fix-cross-platform-build.patch
		remove-unimplemented-bf16-conversions.patch
)

vcpkg_cmake_configure(
	SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
	OPTIONS
		"-DCOREMLTOOLS_SOURCE_DIR=${SOURCE_PATH}"
		"-DProtobuf_PROTOC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-coremltools)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
