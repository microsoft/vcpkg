set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO localspook/zcrc
    REF v${VERSION}
    SHA512 6bbdeb87e29e5b7e36c0c77bd3abd23525f153dac152c9680ab5be22c43c64925aa6eb0ae1ca75f81b5cea3c241785d137f417bb42feae716d62a3ad88c32fc5
    HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DCMAKE_INSTALL_INCLUDEDIR=${CURRENT_PACKAGES_DIR}/include
		-DZCRC_INSTALL_CMAKE_FILES_DIR=${CURRENT_PACKAGES_DIR}/share/zcrc
		-DZCRC_INSTALL_PKGCONFIG_DIR=${CURRENT_PACKAGES_DIR}/share/pkgconfig
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

vcpkg_cmake_config_fixup()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
