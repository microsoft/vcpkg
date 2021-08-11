vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ryan-rsm-McKenzie/bsa
    REF 2.0.2
    SHA512 9cbb7ca890e6a05645f1f217d18f43bc2c02128d4be55973c9d252522f317af6a7798d2c6a20a2449e367cb1eeaf7ca45c5fe9f4517be2a5ae90a74e663b293e
    HEAD_REF master
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
		-DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/bsa")

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/include
	${CURRENT_PACKAGES_DIR}/debug/share
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
