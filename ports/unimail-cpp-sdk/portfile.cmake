set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unimails/unimail-cpp-sdk
    REF "v${VERSION}"
    SHA512 271a29879c98fbd83d70dbd4caa231e8d4688dfd3e390990878b75317e08276ed2f35d06c98fe9659e593f132153fc13596eac4952c6b581ffcfb81e3727854f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DUNIMAIL_TEST=OFF"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/unimailCppSdk)

# file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
