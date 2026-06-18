vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ngcpp/proxy
    REF ${VERSION}
    SHA512 78742fbafb06826260175b8f4fd6ffdb8d089d2f6d5749c572ae1d74063b1cb9c7b647d48f4b28672d921a5b304b8fdac88ebe7c4759117f70473a847f060c7a
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "msft_proxy4")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
