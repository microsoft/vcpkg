if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(FIX_UPSTREAM_421
    URLS https://github.com/DanielChappuis/reactphysics3d/pull/421.patch?full_index=1
    SHA512 71ab7d5024fff100546d1cc934976f15e3ee3fe8df29ff62e1c743d3f0c5f6dad73def0b9d0a560fa423e610cb1388c88c3226d8e2b9f2b1afdf4535204541ff
	FILENAME reactphysics3d-421.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanielChappuis/reactphysics3d
    REF "v${VERSION}"
    SHA512 3ba9ec0e399d2dc46c126e4aa20718b9024f8097f36157e31b469f5135a726d3c0811e79335db970dfab7f258d1506dd4cefa46edca73f5940bf561dc9a5b11a
    HEAD_REF master
    PATCHES
		"${FIX_UPSTREAM_421}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ReactPhysics3D")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
