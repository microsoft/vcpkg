vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO EmbeddedSynth/sonivox
    REF "v${VERSION}"
    SHA512 85ce90ceb23aa0f372f4103881fb12385d9e27f9c58f6a37f6150d65dfc17e86a200d565b5036ad2374d6e3f9acc70136d99033caee6f350a4c250d15755fcbf
    HEAD_REF master
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