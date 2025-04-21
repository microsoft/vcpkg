set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unimails/unimail-cpp-sdk
    REF "v${VERSION}"
    SHA512 9aef9acb99d8bb73bfb11916e6afdce7937d6b8e5947d0aad797db0bb669d5b2ce9485e82b0841fd9f5a91028238f6467144dcc8ac3a5ec0b568b0173e7995c8
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DUNIMAIL_TEST=OFF"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/unimail-cpp-sdk)

# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
