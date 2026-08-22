vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xyo-financial/sdk-cpp
    REF "v${VERSION}"
    SHA512 812b3efb9f1b5455913efa7ee3c83b1d59e36e2a3f59ed1353aa67deda89f6dfdfe9765ec1e26bfaea706e3349e726ff689ccf24efa457532a4f5900a951376c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXYO_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME XYOSDK CONFIG_PATH lib/cmake/XYOSDK)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
