vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aklomp/base64
    REF 3eab8e6ca57f4514dea4fd0ec435967e96371bbe
    SHA512 f31b1ce3bd99dd585686ec540c9713d5d5936b2d58aadfb3f0ef48faeaab1797f2373e14b73578c2f9f8355d1e9d03661e2ed9ed8c4349b4e43e510d2214b5ae
    HEAD_REF master
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME base64 CONFIG_PATH lib/cmake/base64)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(
	INSTALL "${SOURCE_PATH}/LICENSE"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright)
