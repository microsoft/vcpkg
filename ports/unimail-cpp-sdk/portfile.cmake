set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO unimails/unimail-cpp-sdk
    REF "v${VERSION}"
    SHA512 f8e1a657c18d20c3ee5d1082b5752b9d24db1248ff6d013c26129eae383df1f900e3e7f86a8be859a2c6789a29a6ee00f65241f8b84a790486466cb0190a8c24
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
