set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
	REPO cms-patatrack/CLUEstering
    REF ${VERSION}
    SHA512 17bfdc76526623442d264133b8424542f3177a3d6c23c5b1ed8d042bf14651d8658361c97df20d5982287efebc477409a77606aa1a517b0988eb52ac919a6bbf
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/CLUEstering")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
