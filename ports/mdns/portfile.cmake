#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mjansson/mdns
    REF 1.4.1
    SHA512 f1268841b5e4ba40ba62e7e08d55ac7f83b675f76c694976097a1c17dd6c662ced953230a4556b81ff5a39a969c67e01d040f1b6c83b9dd27b2cb0adc6af05b9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMDNS_BUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
