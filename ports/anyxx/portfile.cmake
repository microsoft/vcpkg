vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitfactory-software/anyxx
    REF "${VERSION}"
    SHA512 8ec870b6d7ed65de4d41bd3daa4ae6d1f030f685d017c5f23cdeb7fed4a54a5296288d41a0d3cfc7c916e59d5c5886b403304885c40cc72d6b68d7aacb82b6e1
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
	OPTIONS
		-Danyxx_INSTALL_ONLY=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "anyxx")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
