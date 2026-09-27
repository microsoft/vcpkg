vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitfactory-software/anyxx
    REF "${VERSION}"
    SHA512 ec863592aa55402ea67d41e16881dee45c9cbb7c46b318297b556b8fa84611ec058ec334d980e9c994f590c9d79c7a3de225093a18507c69ce1836fd8d6a8b3c
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
