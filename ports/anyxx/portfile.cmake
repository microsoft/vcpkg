vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitfactory-software/anyxx
    REF "${VERSION}"
    SHA512 2dff8f7def0489a469485f3130d0d7f7dcaec675f46110504b60c7a2b8247ca302b523316011c0172154a4ff833f6e903eea8e99f958cfd4b24d32327095f234
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
