vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rollbear/trompeloeil
    REF v${VERSION}
    SHA512 e29d5424318c9d09adfa37767a5ad2cc074a01d5bb12eb832868d2bf54e67f12310a47b0887b1a6c62eebcdddf4155d940a37a8c93c3547742d91a3ce857dd69
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/trompeloeil)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/include/trompeloeil.hpp")
    message(FATAL_ERROR "Main includes have moved. Please update the forwarder.")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")
