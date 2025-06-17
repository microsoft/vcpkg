set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO localspook/zcrc
    REF "v${VERSION}"
    SHA512 d7d71070815d447b7a6ab27780fe58ade83a912dcb32013403aa0c69fefa478d23b2860e80f15e18b6164dd17bfb3963216e759538f84e7d4b107d5d340fd98c
    HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DZCRC_INSTALL_CMAKE_DIR=share/zcrc
		-DZCRC_INSTALL_PKGCONFIG_DIR=share/pkgconfig
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

vcpkg_cmake_config_fixup()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
