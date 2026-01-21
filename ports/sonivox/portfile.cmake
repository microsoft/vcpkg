vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EmbeddedSynth/sonivox
    REF "v${VERSION}"
    SHA512 d9f8fb18f151ef3ba2352bcd66a97bc71056aab8ab9f78a061ffa475f68a80ede3c2c0deb374ad21eb2c1cb1d7521c3d7f8eeda72640e11f71c3526b275f5468
    HEAD_REF master
	PATCHES "option-install-dependencies.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS 
		-DBUILD_TESTING:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(NOT VCPKG_TARGET_IS_ANDROID)
	vcpkg_copy_tools(TOOL_NAMES sonivoxrender AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(
	PACKAGE_NAME "sonivox"
	CONFIG_PATH lib/cmake/sonivox
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/man")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")