vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bernedom/SI
    REF "${VERSION}"
    SHA512 499bf6cd1c68cf5195f15b94910d4f3973a040c2d217aab4eacaa29bfefc031b441639272cffb4b810fd27ff3a664d55284c1252da5e4504ebc768d1a3567f78
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSI_INSTALL_LIBRARY=ON
        -DSI_BUILD_TESTING=OFF
        -DSI_BUILD_DOC=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME SI CONFIG_PATH share/SI/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
