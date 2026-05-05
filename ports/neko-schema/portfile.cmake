vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO moehoshio/NekoSchema
    REF v1.1.5
    SHA512 a4383927168a06fc50623e8a0cdb4c1d9dabfa8a6f2ae6408aff5b468cd9a3bdca57262187c231231ad70eb2a6b65d5574a824cc0d4be6a43e62c4ecf342ef0b
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNEKO_SCHEMA_BUILD_TESTS=OFF
        -DNEKO_SCHEMA_AUTO_FETCH_DEPS=OFF
        -DNEKO_SCHEMA_ENABLE_MODULE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NekoSchema PACKAGE_NAME nekoschema)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
