include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO KhronosGroup/glslang
	REF 7.13.3496
	SHA512 5c096ed340b03150c3bef16b17cbd44ae7fa88ca55a206ac4a0879ac10895d7025561669ccea33c703c37b9bcca9b8d64ff604a6cdc175fcd3af06051f721367
	HEAD_REF master
    PATCHES
		CMakeLists-targets.patch
	)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DCMAKE_DEBUG_POSTFIX=d
		-DSKIP_GLSLANG_INSTALL=OFF
		-DENABLE_AMD_EXTENSIONS=OFF
		-DENABLE_NV_EXTENSIONS=OFF
	)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/glslang)

vcpkg_copy_pdbs()

file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME glslang)
