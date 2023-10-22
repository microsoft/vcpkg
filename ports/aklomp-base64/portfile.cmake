vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aklomp/base64
    REF e77bd70bdd860c52c561568cffb251d88bba064c
    SHA512 bc0cf64f6a24226a64c51983e8b73b4d4e893b8242bc6ac39361d977996de453d9f95ed0ab68a7544f21b0be1d76ae53af96521207a651c95673b02954cc5bbe
    HEAD_REF master
)

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(
	PACKAGE_NAME base64
	CONFIG_PATH "lib/cmake/base64"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
