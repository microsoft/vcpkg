set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO localspook/zcrc
    REF "v${VERSION}"
    SHA512 1ff2e5f007115062a9846af5017d2cde6e715d27bdcd0a3119f6785e171fa3b471b728a4adae6808d058f7a3ce4a98dd75cf06bac1d300ac39116500077dbde4
    HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH ${SOURCE_PATH}
	OPTIONS
		-DCMAKE_INSTALL_INCLUDEDIR=${CURRENT_PACKAGES_DIR}/include
		-DZCRC_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share/zcrc
		-DZCRC_INSTALL_PKGCONFIG_DIR=${CURRENT_PACKAGES_DIR}/share/pkgconfig
)
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

vcpkg_cmake_config_fixup()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
