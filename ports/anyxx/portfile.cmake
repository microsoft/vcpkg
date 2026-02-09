vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitfactory-software/anyxx
    REF "${VERSION}"
    SHA512 0bf5deb26082a5ec17ff958e11525899e2144af289a37ffe708e77a68b875de9c2cfd1a1285281b1cef9fda8e01d3331fb9689a8fd80cad98f61a0d33edeec7b
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
